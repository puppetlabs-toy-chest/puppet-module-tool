Puppet.setdefaults(:pmt,
                   :modulerepository => ['https://modules.puppetlabs.com',
                                         "The module repository"],
                   :pmtdir => ['$vardir/pmt', "The directory in which module tool data is stored"])

Puppet.settings.use(:pmt)
Puppet.settings.parse
