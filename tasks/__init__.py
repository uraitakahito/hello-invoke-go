"""
Invoke entrypoint, import here all the tasks we want to make available
"""

from invoke import Collection

from tasks import (
    target,
)

# the root namespace
ns = Collection()

# add namespaced tasks to the root
ns.add_collection(target)

ns.configure(
    {
        "run": {
            # this should stay, set the encoding explicitly so invoke doesn't
            # freak out if a command outputs unicode chars.
            "encoding": "utf-8",
        }
    }
)
