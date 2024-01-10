# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Print release notes for a package.

"""

import argparse
import os
import string
import textwrap
import hashlib

def get_package_sha256(tarball_path):
  with open(tarball_path, 'rb') as pkg_content:
    tar_sha256 = hashlib.sha256(pkg_content.read()).hexdigest()
  return tar_sha256


def print_notes(org, repo, version, tarball_path, mirror_host=None,
                deps_method=None, setup_file=None, toolchains_method=None,
                changelog=''):
  file_name = os.path.basename(tarball_path)
  sha256 = get_package_sha256(tarball_path)

  url = 'https://github.com/%s/%s/releases/download/%s/%s' % (
      org, repo, version, file_name)
  mirror_url = 'https://%s/github.com/%s/%s/releases/download/%s/%s' % (
      mirror_host, org, repo, version, file_name) if mirror_host else None
  relnotes_template = string.Template(textwrap.dedent(
      """
      ⚙️ MODULE.bazel setup

      ```
      bazel_dep(name = "${repo}", version = "${version}")
      ```

      ⚙️ WORKSPACE setup

      BZL MOD only!

      📚 Using the rules

      See [the source](https://github.com/${org}/${repo}/tree/v${version}).

      # Changelog

      ${changelog}

      """).strip())
  print(relnotes_template.substitute({
      'changelog': changelog if changelog != 'TBD' else 'First release',
      'org': org,
      'repo': repo,
      'version': version,
  }))


def main():
  parser = argparse.ArgumentParser(
      description='Print release notes for a package')

  parser.add_argument(
      '--org', default='yanndegat', help='Github org name')
  parser.add_argument(
      '--repo', default=None, required=True, help='Repo name')
  parser.add_argument(
      '--version', default=None, required=True, help='Release version')
  parser.add_argument(
      '--tarball_path', default=None,
      required=True, help='path to release tarball')
  parser.add_argument(
      '--mirror_host', default=None,
      help='If provider, the hostname of a mirror for the download url')
  parser.add_argument(
      '--setup_file', default=None,
      help='Alternate name for setup file. Default: deps.bzl')
  parser.add_argument(
      '--deps_method', default=None,
      help='Alternate name for dependencies method. Default: {repo}_dependencies')
  parser.add_argument(
      '--toolchains_method', default=None,
      help='Alternate name for toolchains method. Default: {repo}_toolchains')
  parser.add_argument(
      '--changelog', default=None,
      help='Pre-fill release notes with changes from this file')

  options = parser.parse_args()
  if options.changelog:
    with open(options.changelog, 'r', encoding='utf-8') as f:
      changelog = f.read()
  else:
    changelog = 'TBD'

  print_notes(options.org, options.repo, options.version, options.tarball_path,
              deps_method=options.deps_method,
              changelog=changelog,
              mirror_host=options.mirror_host,
              setup_file=options.setup_file,
              toolchains_method=options.toolchains_method)


if __name__ == '__main__':
  main()
