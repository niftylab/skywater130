# -*- coding: utf-8 -*-

import os
import pkg_resources

from bag.design.module import MosModuleBase


# noinspection PyPep8Naming
class BAG_prim__nmos4_ulvt(MosModuleBase):
    """design module for BAG_prim__nmos4_ulvt.
    """

    yaml_file = pkg_resources.resource_filename(__name__,
                                                os.path.join('netlist_info',
                                                             'nmos4_ulvt.yaml'))

    def __init__(self, database, parent=None, prj=None, **kwargs):
        MosModuleBase.__init__(self, database, self.yaml_file, parent=parent, prj=prj, **kwargs)

