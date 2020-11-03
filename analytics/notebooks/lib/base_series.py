from .common_base import CommonBase
from .run import Run

class BaseSeries(CommonBase):

    def __init__(self, run:Run):
        CommonBase.__init__(self)
        self.run = run

    def run_dir(self):
        return self.run.run_dir
