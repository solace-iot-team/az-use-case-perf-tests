# Solace PubSub+ Performance Analytics

Solace PubSub+ Performance Analytics is based on [Jupyter Notebooks](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html). 

## Prerequisits

* Make yourself familiar with Jupyter at [Jupyter Project Page ](https://jupyter.org)
* Get a recent Python Release (>= 3.8.5)
* Install these Python packages 
  * jupyter
  * pandas
  * jsonpath-ng
  * matplotlib
  * seaborn
  * plotly
  

````bash
pip3 install jupyter
pip3 install pandas
pip3 install jsonpath-ng
pip3 install matplotlib
pip3 install seaborn
pip3 install plotly
````
* Install Jupyter extensions [Jupyter extensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions)
````bash
pip3 install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user
jupyter nbextension enable python-markdown/main

````


## Starting Jupyter Notebook Server

- Start Jupyter notebook server and your browser should automatically point to the default welcome page of Jupyter. 

````bash
az-use-case-perf-tests/analytics/jupyter notebook
```` 

- Adjust `Analyse_single_run` notebook and point to the testrun for initial analytics. 

## Background Information
In `support.py` is a collection of Python helper functions to parse test run raw data and expose as tailored data structures for Pandas. 
