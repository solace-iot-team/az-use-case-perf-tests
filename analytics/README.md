# Analytics

Analytics are based on [Jupyter Notebooks](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html).

## Prerequisites

### Mac

  * Tested with Python>=3.8.5

````bash
pip3 install jupyter

pip3 install pandas

pip3 install jsonpath-ng

pip3 install matplotlib

pip3 install seaborn

pip3 install plotly

pip3 install jupyter_contrib_nbextensions

jupyter contrib nbextension install --user

jupyter nbextension enable python-markdown/main
````

### Ubuntu

* Tested with Python=3.6.9

````bash

sudo -H python3 -m pip install jupyter

sudo -H python3 -m pip install pandas

sudo -H python3 -m pip install jsonpath-ng

sudo -H python3 -m pip install matplotlib

sudo -H python3 -m pip install seaborn

sudo -H python3 -m pip install plotly

sudo -H python3 -m pip install jupyter_contrib_nbextensions

jupyter contrib nbextension install --user

jupyter nbextension enable python-markdown/main

````

## Run

[Examples to run the analytics reports](./auto-run).


---
The End.
