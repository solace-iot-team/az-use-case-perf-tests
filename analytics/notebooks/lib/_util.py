# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

"""Collection of utility classes and functions."""

import datetime

def to_date(text: str, pattern: str) -> datetime:
    """Converts text to a datetime object using pattern"""
    return datetime.datetime.strptime(text, pattern)

import sys, os, logging
from distutils.util import strtobool

PACKAGE_NAME="perf-analytics"
ANALYTICS_ENABLE_LOGGING_ENV="ANALYTICS_ENABLE_LOGGING"
ANALYTICS_LOG_FILE_ENV="ANALYTICS_LOG_FILE"

"""Check Python Version """
_PY3_MIN = sys.version_info[:2] >= (3, 8)
if not _PY3_MIN:
    sys.stderr.write(
        '>>> ERROR: %s require a minimum of Python version 3.6.9. Current version: %s."}' % (PACKAGE_NAME, ''.join(sys.version.splitlines()))
    )
    sys.exit(1)

""" initialize logging """
ENABLE_LOGGING = False  # False to disable
enableLoggingEnvVal = os.getenv(ANALYTICS_ENABLE_LOGGING_ENV)
loggingPathEnvVal = os.getenv(ANALYTICS_LOG_FILE_ENV)

if enableLoggingEnvVal is not None and enableLoggingEnvVal != '':
    try:
        ENABLE_LOGGING = bool(strtobool(enableLoggingEnvVal))
    except ValueError:
        raise ValueError(">>> ERROR: invalid value for env var: '{}'={}'. use 'true' or 'false' instead.".format(ANALYTICS_ENABLE_LOGGING_ENV, enableLoggingEnvVal))

logFile = './analytics.log'

if ENABLE_LOGGING:
    if loggingPathEnvVal is not None and loggingPathEnvVal != '':
        logFile = loggingPathEnvVal
    logging.basicConfig(filename=logFile,
                        filemode='w',
                        level=logging.DEBUG,
                        format='%(asctime)s - %(name)s - %(levelname)s - %(funcName)s(): %(message)s')
    logging.info('%s start #############################################################################################', PACKAGE_NAME)


def testPrintMe():
    print("enableLoggingEnvVal={}".format(enableLoggingEnvVal))
    print("logFile={}".format(logFile))

def testLogMe():
    logging.debug("hello world from %s", PACKAGE_NAME)


 ###
 # The End.   