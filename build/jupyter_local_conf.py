import os
import sys

from hybridcontents import HybridContentsManager
from notebook.services.contents.largefilemanager import LargeFileManager

import getpass


username = getpass.getuser()

c = get_config()

c.NotebookApp.terminals_enabled = True

c.NotebookApp.contents_manager_class = HybridContentsManager

c.HybridContentsManager.manager_classes = {
    "s3": LargeFileManager,
    "git": LargeFileManager,
}

c.HybridContentsManager.manager_kwargs = {
    "s3": {"root_dir": "/mnt/s3fs"},
    "git": {"root_dir": "/git"},
}


def no_spaces(path):
    return " " not in path


c.HybridContentsManager.path_validators = {}


def scrub_output_pre_save(path, model, contents_manager):
    """scrub output before saving notebooks"""
    # only run on notebooks
    if model["type"] != "notebook":
        return

    for cell in model["content"]["cells"]:
        if cell["cell_type"] != "code":
            continue
        cell["outputs"] = []
        cell["execution_count"] = None


c.LargeFileManager.pre_save_hook = scrub_output_pre_save
