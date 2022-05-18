#!/bin/env python3

class FilterModule(object):
    SUPPORTED_KERNELS = ['linux', 'zen', 'lts', 'hardened']

    def filters(self):
        return dict((f.__name__, f) for f in [
                self.to_kernel_list,
                self.default_kernel,
                self.microcode_package,
                self.kernel_package,
                self.kernel_title,
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
            for k in kernels:
                if not isinstance(k, str) or k.lower() not in self.SUPPORTED_KERNELS:
                    raise ValueError('{} => {} not in {}'
                            .format(kernels, k, ', '.join(self.SUPPORTED_KERNELS)))
                kernel_list.append(k)
        else:
            raise ValueError(f'{kernels} is wrong type')
        if not kernel_list:
            raise ValueError('must define at least one kernel')
        return kernel_list

    def default_kernel(self, kernels):
        if isinstance(kernels, dict):
            for k, v in kernels.items():
                if isinstance(v, str) and v.lower() == 'default':
                    if k.lower() in self.SUPPORTED_KERNELS:
                        return k
        return self.to_kernel_list(kernels)[0]

    def microcode_package(self, cpus):
        for cpu in cpus:
            if cpu == 'GenuineIntel':
                return 'intel-ucode'
            elif cpu == 'AuthenticAMD':
                return 'amd-ucode'
        raise ValueError(f'unsupported CPU manufacturer {cpus}')

    def kernel_package(self, kernel):
        if not isinstance(kernel, str):
            raise ValueError('kernel name should be of type str')
        kernel = kernel.lower()
        if kernel not in self.SUPPORTED_KERNELS:
            raise ValueError(f'kernel "{kernel}" is not supported')
        return kernel if kernel == 'linux' else f'linux-{kernel}'

    def kernel_title(self, kernel):
        if not isinstance(kernel, str):
            raise ValueError('kernel name should be of type str')
        kernel = kernel.lower()
        if kernel not in self.SUPPORTED_KERNELS:
            raise ValueError(f'kernel "{kernel}" is not supported')
        return 'Arch Linux' if kernel == 'linux' else f'Arch Linux ({kernel})'
