#!/bin/bash
#
# Adopted from https://github.com/tmcdonell/travis-scripts/blob/dfaac280ac2082cd6bcaba3217428347899f2975/update-accelerate-buildbot.sh

set -e

export LIBCUSPATIAL_FILE=`conda build conda/recipes/libcuspatial --python=$PYTHON --output`
export CUSPATIAL_FILE=`conda build conda/recipes/cuspatial --python=$PYTHON --output`

SOURCE_BRANCH=master
CUDA_REL=${CUDA_VERSION%.*}

# Restrict uploads to master branch
if [ ${GIT_BRANCH} != ${SOURCE_BRANCH} ]; then
  echo "Skipping upload"
  return 0
fi

if [ -z "$MY_UPLOAD_KEY" ]; then
    echo "No upload key"
    return 0
fi

if [ "$UPLOAD_LIBCUDF" == "1" ]; then
  LABEL_OPTION="--label main --label cuda${CUDA_REL}"
  echo "LABEL_OPTION=${LABEL_OPTION}"

  test -e ${LIBCUSPATIAL_FILE}
  echo "Upload libcuspatial"
  echo ${LIBCUSPATIAL_FILE}
  anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --force ${LIBCUSPATIAL_FILE}
fi

if [ "$UPLOAD_CUDF" == "1" ]; then
  LABEL_OPTION="--label main --label cuda9.2 --label cuda10.0"
  echo "LABEL_OPTION=${LABEL_OPTION}"

  test -e ${CUSPATIAL_FILE}
  echo "Upload dask-cudf"
  echo ${CUSPATIAL_FILE}
  anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --force ${CUSPATIAL_FILE}
fi

