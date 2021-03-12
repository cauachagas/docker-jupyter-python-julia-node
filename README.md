# Python, Julia and Node

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/cauachagas/jupyter-python-julia-node/HEAD)

Click on the badge above and run Python, Julia or Node.js on the Jupyter Notebook without having to install anything locally.

## Binder: how it works?

Binder will search for a dependency file, such as requirements.txt or environment.yml, in the repository's root directory ([more details on more complex dependencies in documentation](http://mybinder.readthedocs.io/en/latest/using.html#preparing-a-repository-for-binder)). The dependency files will be used to build a Docker image. If an image has already been built for the given repository, it will not be rebuilt. If a new commit has been made, the image will automatically be rebuilt. 

## References

https://github.com/jupyter/docker-stacks

https://www.npmjs.com/package/magicpatch

https://www.npmjs.com/package/dstools
