#!/usr/bin/env python3
"""Repackage the checked-in SDK without rebuilding or changing its binaries."""
from pathlib import Path
import shutil
import plistlib
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'ios/Source/framework'
DEST = ROOT / 'ios/flutter_alibc/Frameworks'


def run(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.STDOUT)


def bundle_version(value):
    # Apple requires a numeric major.minor.patch release version. Old SDKs
    # use four components and suffixes such as -SNAPSHOT and -bc.
    match = re.match(r"^(\d+)(?:\.(\d+))?(?:\.(\d+))?", str(value))
    if not match:
        raise ValueError(f"Invalid SDK bundle version: {value!r}")
    return '.'.join(str(int(part or 0)) for part in match.groups())


def main():
    DEST.mkdir(parents=True, exist_ok=True)
    for original in sorted(SOURCE.rglob('*.framework')):
        name = original.stem
        architectures = run('xcrun', 'lipo', '-archs', str(original / name)).split()
        with tempfile.TemporaryDirectory() as directory:
            arguments = ['xcodebuild', '-create-xcframework']
            for platform, wanted in [('iphoneos', ['arm64', 'armv7']),
                                     ('iphonesimulator', ['x86_64', 'i386'])]:
                selected = [arch for arch in wanted if arch in architectures]
                if not selected:
                    continue
                framework = Path(directory) / platform / original.name
                shutil.copytree(original, framework)
                binary = framework / name
                if len(selected) == 1:
                    run('xcrun', 'lipo', str(original / name), '-thin', selected[0], '-output', str(binary))
                else:
                    run('xcrun', 'lipo', str(original / name), *sum((['-extract', arch] for arch in selected), []), '-output', str(binary))
                info_path = framework / 'Info.plist'
                info = plistlib.loads(info_path.read_bytes()) if info_path.exists() else {}
                info.update({
                    'CFBundleIdentifier': f'com.alibaba.sdk.{name}',
                    'CFBundleExecutable': name,
                    'CFBundleName': name,
                    'CFBundlePackageType': 'FMWK',
                    'CFBundleShortVersionString': bundle_version(info.get('CFBundleShortVersionString', '1.0')),
                    'CFBundleVersion': bundle_version(info.get('CFBundleVersion', '1')),
                    'CFBundleSupportedPlatforms': ['iPhoneOS' if platform == 'iphoneos' else 'iPhoneSimulator'],
                })
                info_path.write_bytes(plistlib.dumps(info))
                modules = framework / 'Modules'
                modules.mkdir(exist_ok=True)
                modulemap = modules / 'module.modulemap'
                if not modulemap.exists():
                    modulemap.write_text(f'framework module {name} {{\n  umbrella "Headers"\n  export *\n  module * {{ export * }}\n}}\n')
                arguments.extend(['-framework', str(framework)])
            output = DEST / f'{name}.xcframework'
            if output.exists():
                shutil.rmtree(output)
            print(run(*arguments, '-output', str(output)).strip())


if __name__ == '__main__':
    main()
