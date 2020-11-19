# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Jochen Traunecker (jochen.traunecker@solace.com)
# ---------------------------------------------------------------------------------------------

import glob
import os.path
from os import path


class CommonBase:

    def files_in_folder_by_pattern(self, folder, pattern):
        return glob.glob(folder + "/" + pattern)

    def check_folder_exists(self, path_to_folder: str, raise_exception: bool = False,
                            msg: str = "directory does not exist") -> bool:
        exists_check = (path.exists(path_to_folder) and os.path.isdir(path_to_folder))
        if (not exists_check and raise_exception):
            raise SystemExit(f'[ERROR] [EXITING] {msg}:{path_to_folder}')
        return exists_check

    def check_file_exists(self, path_to_file: str, raise_exception: bool = False,
                          msg: str = "file does not exist") -> bool:
        exists_check = (path.exists(path_to_file) and os.path.isfile(path_to_file))
        if (not exists_check and raise_exception):
            raise SystemExit(f'[ERROR] [EXITING] {msg}:{path_to_file}')
        return exists_check
