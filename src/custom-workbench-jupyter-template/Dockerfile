# Use latest CUDA base image that supports both Pytorch and TensorFlow
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

#########################
# Environment Variables #
#########################
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8
ENV PYTHON_VERSION=3.10

# Run setup as root
USER root

##############################
# Install Packages and Tools #
##############################

# Install system dependencies
# Run setup as root
RUN apt-get update --yes && \
    apt-get install -yq --no-install-recommends \
    # basic necessities
    locales \
    aria2 \
    bzip2 \
    curl \
    jq \
    nano \
    procps \
    tree \
    unzip \
    vim \
    sudo \
    wget \
    lsof \
    # gcloud CLI dependencies
    apt-transport-https \
    ca-certificates \
    gnupg \
    # aws CLI dependencies
    # > debian names glibc as libc6
    libc6 \
    groff \
    # gcc compiler
    build-essential \
    locales \
    # for ssh-agent and ssh-add
    keychain \
    # git
    git \
    openssh-client \
    # Enable clipboard
    xclip \
    software-properties-common \
    # Fonts for R plotting
    fonts-dejavu \
    software-properties-common \
    dirmngr

# Install conda using miniforge. When changing the version, update the sha256
# checksum as well
ARG MINIFORGE_VERSION="25.3.1-0"
ARG MINIFORGE_ARCH="Linux-x86_64"
ARG MINIFORGE_SHA256="376b160ed8130820db0ab0f3826ac1fc85923647f75c1b8231166e3d559ab768"
ARG CONDA_PATH="/opt/conda"
ARG CONDA_ENV="jupyter"
ENV CONDA_ENV=$CONDA_ENV
RUN wget --progress=bar:force -O Miniforge3.sh \
    "https://github.com/conda-forge/miniforge/releases/download/$MINIFORGE_VERSION/Miniforge3-$MINIFORGE_VERSION-$MINIFORGE_ARCH.sh" \
    && echo "$MINIFORGE_SHA256 Miniforge3.sh" | sha256sum --check \
    && /bin/bash Miniforge3.sh -b -p "$CONDA_PATH" \
    && rm Miniforge3.sh \
    && "$CONDA_PATH/bin/mamba" create -n "$CONDA_ENV" -y -c conda-forge \
        python=$PYTHON_VERSION \
        pip=25.0.1 \
        r-base=4.4.2 \
        # Install lsb-release in conda since it relies on python
        lsb-release \
    && "$CONDA_PATH/bin/mamba" clean -afy \
    && update-alternatives --install /usr/bin/python3 python3 "$CONDA_PATH/envs/$CONDA_ENV/bin/python${PYTHON_VERSION}" 1

ENV PATH=$CONDA_PATH/envs/$CONDA_ENV/bin:$CONDA_PATH/bin:$PATH

# Generate locales and install TeX for nbconvert
RUN locale-gen en_US.UTF-8 && \
    apt-get update -y && apt-get install -yq --no-install-recommends \
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic

# Install Node 24 (needed for jupyterlab)
RUN mkdir -p /etc/apt/keyrings \
    && wget -qO- https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -yq --no-install-recommends \
       nodejs

# Install Java 17 for Workbench CLI
RUN apt-get update -y && apt-get install -yq --no-install-recommends \
    openjdk-17-jdk

# Install gcloud CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    wget -qO- https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    apt-get update -y && apt-get install -yq --no-install-recommends \
    google-cloud-cli \
# Clean up the apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install aws CLI with mamba since it relies on python
RUN mamba install -n "$CONDA_ENV" -y -c conda-forge awscli=2.22.15 \
    && mamba clean -afy

# Configure CUDA library paths
# hadolint ignore=DL3059
RUN ln -s /usr/local/cuda-11.8 /usr/local/cuda \
    && ldconfig

##############
# User Setup #
##############

ENV JUPYTER_USER jupyter
ENV JUPYTER_UID 1000
ENV JUPYTER_USER_HOME_DIR /home/$JUPYTER_USER

# Create the Jupyter user with /bin/bash as the default shell
RUN useradd -l -m -N -d $JUPYTER_USER_HOME_DIR \
                     -u $JUPYTER_UID \
                     -g users \
                     -s /bin/bash $JUPYTER_USER \
# Grant sudo privileges to the jupyter user
    && echo "$JUPYTER_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$JUPYTER_USER \
    && chmod 0440 /etc/sudoers.d/$JUPYTER_USER \
# Disable password authentication for the jupyter user. Without this, the user
# will be prompted for a password if sudo access is removed or limited.
    && echo "Defaults:$JUPYTER_USER !authenticate" >> /etc/sudoers \
    && chown -R root:sudo /usr/local \
    && chmod -R g+w /usr/local \
    && chown -R $JUPYTER_USER: "$CONDA_PATH"

# Add /home/jupyter/.local/bin to the Jupyter user's PATH
ENV PATH=$JUPYTER_USER_HOME_DIR/.local/bin:$PATH
# Ignore expression expansion in single quotes. We want to cat the exact string into .bashrc
# hadolint ignore=SC2016
RUN echo 'export PATH="/home/jupyter/.local/bin:$PATH"' >> $JUPYTER_USER_HOME_DIR/.bashrc \
    && printf 'export PATH="%s/bin:%s/bin:$PATH"\n' "$CONDA_PATH/envs/$CONDA_ENV" "$CONDA_PATH" >> $JUPYTER_USER_HOME_DIR/.bashrc

# Allow .bashrc to be sourced in non-interactive shells, i.e. when launching a Jupyter notebook kernel
RUN sed -i '/^# If not running interactively/,/esac/d' $JUPYTER_USER_HOME_DIR/.bashrc \

# Give jupyter user ownership of its home directory
    && chown -R $JUPYTER_USER:users $JUPYTER_USER_HOME_DIR

###########################
# Install python packages #
###########################

# Remaining setup are performed as the jupyter user
USER $JUPYTER_USER
WORKDIR $JUPYTER_USER_HOME_DIR

# Install Python dependencies
RUN mamba install -n "$CONDA_ENV" -y -c conda-forge \
    conda-content-trust=0.2.0 \
    gradio=5.49.1 \
    matplotlib=3.10.1 \
    matplotlib-venn=1.1.1 \
    nb_conda=2.2.1 \
    nb_conda_kernels=2.5.1 \
    numpy=1.26.0 \
    pandas=2.2.1 \
    pandas-gbq=0.27.0 \
    pandas-profiling=3.0.0 \
    plotly=6.0.0 \
    plotnine=0.14.5 \
    pyarrow=17.0.0 \
    pycares=4.5.0 \
    pydata-google-auth=1.9.0 \
    python-lzo=1.15 \
    py-bgzip=0.5.0 \
    regex=2024.11.6 \
    scikit-learn=1.6.1 \
    scikit-learn-intelex=2025.1.0 \
    scipy=1.15.2 \
    seaborn=0.13.2 \
    # Google cloud client libraries
    google-api-core-grpc=2.24.1 \
    google-api-python-client=2.162.0 \
    google-apitools=0.5.32 \
    google-auth-httplib2=0.2.0 \
    google-auth-oauthlib=1.0.0 \
    google-cloud-aiplatform=1.72.0 \
    google-cloud-artifact-registry=1.8.4 \
    google-cloud-bigtable=2.29.0 \
    google-cloud-bigquery=3.25.0 \
    google-cloud-bigquery-connection=1.16.1 \
    google-cloud-bigquery-datatransfer=3.19.0 \
    google-cloud-bigquery-storage=2.27.0 \
    google-cloud-datastore=2.20.2 \
    google-cloud-core=2.4.1 \
    google-cloud-storage=2.14.0 \
    # Jupyter lab and extensions
    jupyterlab=4.3.4 \
    jupyterlab-git=0.51.2 \
    jupyterlab_widgets=3.0.13 \
    jupyter-server-proxy=4.4.0 \
    jupytext=1.16.4 \
    ipykernel=6.29.5 \
    ipywidgets=8.1.5 \
    nbdime=4.0.2 \
    pygments=2.18.0 \
    # PyTorch dependencies
    Cython=3.0.11 \
    sympy=1.13.3 \
    triton=3.1.0 \
    && mamba clean -afy

# Note: if adding any additional pip packages, verify that they do not alter any
# of the packages installed with conda. Otherwise, conda may not know about the
# packages and behavior could be undefined (although interoperability continues
# to be improved)

# Install PyTorch, TorchVision, and TorchAudio with CUDA 11.8 support, but do
# not include CUDA libraries as they are already provided by the base image.
RUN python3 -m pip install \
    torch==2.0.1 \
    torchvision==0.15.2 \
    torchaudio==2.0.2 \
    --index-url https://download.pytorch.org/whl/cu118 \
    --no-cache-dir \
    --no-deps

# Install TensorFlow with CUDA 11.8 support
# Disable DL3042 multiple consecutive RUN instructions for image layer optimization
# as installing pytorch tensorflow each create large layers.
# hadolint ignore=DL3059
RUN python3 -m pip install --no-cache-dir tensorflow==2.14.0

# Install hail and its dependencies via pip, without updating any existing
# packages. This was generated by comparing the output of `pip freeze` before
# and after installing hail.
# Disable DL3042 multiple consecutive RUN instructions for image layer optimization
# as installing pytorch tensorflow each create large layers.
# hadolint ignore=DL3059
RUN --mount=type=bind,source=requirements-no-deps.txt,target=/requirements-no-deps.txt \
    python3 -m pip install --no-cache-dir --no-deps -r /requirements-no-deps.txt

###################################
# Install R Packages and IRkernel #
###################################
# Install R packages using mamba
# Including IRkernel for Jupyter integration and additional data science packages.
RUN mamba install -n "$CONDA_ENV" -y -c conda-forge \
    r-tidyverse=2.0.0 \
    r-caret=6.0_94 \
    r-randomforest=4.7_1.2 \
    r-tidymodels=1.3.0 \
    r-rmarkdown=2.29 \
    r-shiny=1.10.0 \
    r-ggplot2=3.5.1 \
    r-bigrquery=1.5.1 \
    r-irkernel=1.3.2 \
    && mamba clean -afy \
    && R -e "IRkernel::installspec(user = TRUE)"

############################
# Configure Jupyter Server #
############################

# Create jupyter server user config directory and copy over server config
ENV JUPYTER_CONFIG_DIR $JUPYTER_USER_HOME_DIR/.jupyter
RUN mkdir -p $JUPYTER_CONFIG_DIR
COPY jupyter_server_config.py $JUPYTER_CONFIG_DIR

# Apply modified python and r kernel configurations to source .bashrc during kernel launch
COPY ipython_kernel.json $JUPYTER_USER_HOME_DIR/.local/share/jupyter/kernels/python3/kernel.json
COPY ir_kernel.json $JUPYTER_USER_HOME_DIR/.local/share/jupyter/kernels/ir/kernel.json

# Set the default shell to bash
ENV SHELL=/bin/bash

EXPOSE 8888
ENTRYPOINT ["jupyter", "lab"]
