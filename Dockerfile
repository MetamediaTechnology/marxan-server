ARG TARGETPLATFORM=linux/amd64
FROM ubuntu:18.04 AS server

# Set environment variables
ENV MARXAN_SERVER_DIRECTORY=/marxan-server/
ENV PATH /miniconda3/bin:$PATH
ENV CONDA_DEFAULT_ENV=base 
ENV GDAL_DATA=/miniconda3/share/gdal 
ENV PROJ_LIB=/miniconda3/share/proj 

# Install system dependencies and download miniconda
RUN apt-get update && \
    apt-get install -y wget bash && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda3 && \
    rm ./Miniconda3-latest-Linux-x86_64.sh

# Install python packages
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda install -y tornado psycopg2 pandas gdal colorama psutil sqlalchemy && \
    pip install mapbox aiopg aiohttp google-cloud-logging -q

# Copy application files
COPY . /marxan-server/.

# Create vanilla server files
#COPY ./server.dat.default ./marxan-server/server.dat
COPY ./server.dat.docker ./marxan-server/server.dat
COPY ./users/admin/user.dat.default ./marxan-server/users/admin/user.dat
COPY ./marxan-server.log.default ./marxan-server/marxan-server.log
COPY ./runlog.dat.default ./marxan-server/runlog.dat

# move favicon to the tornado static file folder
COPY ./favicon.ico ./marxan-client/build/favicon.ico 

# Entry point
ENTRYPOINT [ "conda", "run", "-n", "base", "python", "/marxan-server/server.py" ]
