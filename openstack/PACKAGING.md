# Packaging OpenStack

## Create tar package that RPM spec file requrired

    # git clone https://github.com/openstack/nova
    # cd nova
    # PBR_VERSION=2013.2.3 python setup.py sdist
    # ls dist

## Create RPM package

    # git clone https://github.com/openstack/nova
    # cd nova
    # python setup.py bdist_rpm

## More info

<https://wiki.openstack.org/wiki/Packaging>

<https://repos.fedorapeople.org/repos/openstack>

<https://repos.fedorapeople.org/repos/openstack-m>
