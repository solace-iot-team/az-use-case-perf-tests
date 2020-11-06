# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

from .common_base import CommonBase

class BaseSeries(CommonBase):

    def __init__(self, run):
        CommonBase.__init__(self)
        self.run = run

    def run_dir(self):
        return self.run.run_dir
