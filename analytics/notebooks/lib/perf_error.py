# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

class PerfError(Exception):

    def __init__(self, message:str):
        self.message = message

    def __str__(self):
        return f'[PerfError [message:{self.message}]]'