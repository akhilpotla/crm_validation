.PHONY: clean features lint requirements

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = [OPTIONAL] your-bucket-for-syncing-data (do not include 's3://')
PROFILE = default
PROJECT_NAME = crm_validation
PYTHON_INTERPRETER = python3
PYTHON = $(PYTHON_INTERPRETER) -m

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Default commands
default: features models

## Install Python Dependencies
# run `conda activate $(PROJECT_NAME)` before running this command
requirements:
	conda env update --file environment.yml

## Save Environment
save-environment:
	conda env export > environment.yml

## Make Features
features:
	$(PYTHON) src.features.build_features

## Run the models
models: train-models predict-models

## Run and train the models
train-models:
	$(PYTHON) src.models.train_model

## Run the models to make predictions
predict-models:
	$(PYTHON) src.models.predict_model

## Make all the plots
plots:
	$(PYTHON) src.visualization.visualize

## Run tests
test:
	pytest -q tests/

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Delete all the figures
clean-figures:
	rm reports/figures/*

## Lint using flake8
lint:
	flake8 src
