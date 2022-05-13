#!/bin/env python3

class FilterModule(object):
    SUPPORTED_KERNELS = ['linux', 'zen', 'lts', 'hardened']

    def filters(self):
        return dict((f.__name__, f) for f in [
                self.to_kernel_list,
                self.default_kernel,
                self.microcode_packages,
            ])

    def _is_install_kernel(self, state):
        if state is None:
            return False
        if isinstance(state, bool):
            return state
        if isinstance(state, int):
            return state > 0
        if isinstance(state, str):
            return state.lower() in {'install', 'default', 'present', 'latest'}
        return False

    def to_kernel_list(self, kernels):
        if kernels is None:
            kernels = []
        if isinstance(kernels, dict):
            kernels = [k for k, v in kernels.items() if self._is_install_kernel(v)]
        if isinstance(kernels, str):
            kernels = [k.strip() for k in kernels.split(',')]
        kernel_list = []
        if isinstance(kernels, list) or isinstance(kernels, set):
            for f in kernels:
                if not isinstance(f, str) or f not in self.SUPPORTED_KERNELS:
                    raise ValueError('{} => {} not in {}'
                            .format(kernels, f, ', '.join(self.SUPPORTED_KERNELS)))
                kernel_list.append(f)
        else:
            raise ValueError(f'{kernels} is wrong type')
        if not kernel_list:
            raise ValueError('must define at least one kernel')
        return kernel_list

    def default_kernel(self, kernels):
        if isinstance(kernels, dict):
            for k in self.SUPPORTED_KERNELS:
                v = kernels.get(k)
                if isinstance(v, str) and v.lower() == 'default':
                    return k
        return self.to_kernel_list(kernels)[0]

    def microcode_packages(self, cpus):
        pkgs = set()
        for cpu in cpus:
            if cpu == 'GenuineIntel':
                pkgs.add('intel-ucode')
            elif cpu == 'AuthenticAMD':
                pkgs.add('amd-ucode')
        return list(pkgs)
