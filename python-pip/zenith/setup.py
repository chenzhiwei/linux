try:
    from setuptools import setup, find_packages
except ImportError:
    from distutils.core import setup, find_packages

setup(
    name="zenith",
    version="0.0.1",
    packages=find_packages(exclude=["tests"]),
    description="Zenith sample project",
    install_requires=[""],
    entry_points={
        "console_scripts": [
            "zenith=zenith.app:main"
        ]
    }
)
