TERRAFORM_VERSIONS = {
    "linux_amd64":{
        "version": "1.5.7",
        "sha256": "c0ed7bc32ee52ae255af9982c8c88a7a4c610485cf1d55feeb037eab75fa082c",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64":{
        "sha256": "f4b4ad7c6b6088960a667e34495cae490fb072947a9ff266bf5929f5333565e4",
        "version": "1.5.7",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64":{
        "version": "1.5.7",
        "sha256": "b310ec0e626e9799000cfc8e30247cd827cf7f8030c8e0400257c7f111e93537",
        "os" : "darwin",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64":{
        "version": "1.5.7",
        "sha256": "db7c33eb1a446b73a443e2c55b532845f7b70cd56100bec4c96f15cfab5f50cb",
        "os" : "darwin",
        "arch": "arm64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}

TFLINT_VERSIONS = {
    "linux_amd64":{
        "version": "0.50.0",
        "sha256": "ceb65a64b7b2b231eac9c24c32cf67cb7d7382ae18558f0dfadef2b8bff8627c",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64":{
        "sha256": "9060eb74e0278fe14a414447de8c9b61effd7f2d60e7bb8047ebcda9c6ed4f6f",
        "version": "0.50.0",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64":{
        "version": "0.50.0",
        "sha256": "655df842f36e3bf4d61870e5669d98f91d0d6cb1adea07ebfe1d5fb6d0e68b97",
        "os" : "darwin",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64":{
        "version": "0.50.0",
        "sha256": "59672f1df572f115ec6452ee1ba71a70900d8e9ab8546ccd11d62ebb325a9d3f",
        "os" : "darwin",
        "arch": "arm64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}

TFDOC_VERSIONS = {
    "linux_amd64":{
        "version": "0.17.0",
        "sha256": "8e436d0c44db49c2ccd95deede05c3deba324b34a274be06cd9ba9cdf644e795",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64":{
        "sha256": "4189c4d0b418e5bcc642836b7f73e80d5d4d82b75ada73a7b78f923588d5f765",
        "version": "0.17.0",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64":{
        "version": "0.17.0",
        "sha256": "846c0a40116f748aa900bb9abb704b34e40657d9f9acc807ab94b66355c0eb2e",
        "os" : "darwin",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64":{
        "version": "0.17.0",
        "sha256": "23d83eb036154a3de1a2af82e6f772b06bd6df08398208d43c8ca56f69d0456c",
        "os" : "darwin",
        "arch": "arm64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}

TOFU_VERSIONS = {
    "linux_amd64":{
        "version": "1.6.0-rc1",
        "sha256": "c810fa64d7147df4272681360ef5bc9a366e574bfdabd6b88b18e2c36c3b1aee",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
    },
    "linux_arm64":{
        "sha256": "c04c52c5afd4a0417fcf9c7ad0d7ff05748983549ae830ee451ba77de0bd776c",
        "version": "1.6.0-rc1",
        "os" : "linux",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        "target_compatible_with" : [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
    },
    "darwin_amd64":{
        "version": "1.6.0-rc1",
        "sha256": "91cf2d546c47f8c5c6f82f8c0f80f23812a258abbcaa7cc13c99a521af12fdcb",
        "os" : "darwin",
        "arch": "amd64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:x86_64",
        ],
    },
    "darwin_arm64":{
        "version": "1.6.0-rc1",
        "sha256": "fe70b24e7086d309ce5b16b63ec32d3e932e181b713028d2400fa7a333b71ba1",
        "os" : "darwin",
        "arch": "arm64",
        "exec_compatible_with": [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
        "target_compatible_with" : [
            "@platforms//os:osx",
            "@platforms//cpu:aarch64",
        ],
    },
}
