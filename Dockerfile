FROM jupyter/base-notebook:latest

USER root

RUN conda clean --all

ENV PATH="/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG julia_version="1.5.3"

# SHA256 checksum
ARG julia_checksum="f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1"

# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION="${julia_version}"

RUN mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)"/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    echo "${julia_checksum} *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir "${JULIA_PKGDIR}" && \
    chown "${NB_USER}" "${JULIA_PKGDIR}" && \
    fix-permissions "${JULIA_PKGDIR}"

# Add ijavascript dependences
RUN apt-get update && apt-get install -y gcc g++ make

ENV NODE_PATH=/opt/conda/lib/node_modules

# Install ijavascript and magicpatch
RUN npm install --prefix "/usr/local" -g --unsafe-perm ijavascript magicpatch

RUN ijsinstall

RUN magicpatch-install

# Remove ijavascript dependencies
RUN apt-get autoremove -y gcc g++ make

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Alternative - conda install
RUN pip3 install matplotlib plotly pandas numpy --no-cache-dir

ENV PYTHON="/opt/conda/bin/python"

ENV CONDA="/opt/conda/bin/conda"

# Julia packages
RUN julia -e 'import Pkg; Pkg.update()' && \
    julia -e "using Pkg; pkg\"add PyCall IJulia PyPlot Plots\"; pkg\"precompile\""

# move kernelspec out of home 
RUN mv "${HOME}/.local/share/jupyter/kernels/"* "${CONDA_DIR}/share/jupyter/kernels/" && \
    chmod -R go+rx "${CONDA_DIR}/share/jupyter"

RUN rm -rf "${HOME}/.local" && \
    rm -rf /tmp/*

USER jovyan

# Additional packages
RUN npm install dstools

# RUN pip3 install xxxx --no-cache-dir

# RUN conda install xxxx -c channel && conda clean --all
