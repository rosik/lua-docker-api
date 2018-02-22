package = 'dockerapi'
version = 'scm-1'
source  = {
    url    = 'git@gitlab.com:tarantool/ib-core/dockerapi.git';
    branch = 'master';
}
description = {
    summary  = "Tarantool + Docker = ❤";
    homepage = 'https://gitlab.com/tarantool/ib-core/dockerapi';
    maintainer = "Yaroslav Dynnikov <yaroslav.dynnikov@gmail.com>";
    license  = 'BSD2';
}

dependencies = {
    'lua >= 5.1';
}

build = {
    type = 'none';
    install = {
        lua = {
            ['dockerapi.init'] = 'init.lua';
            ['dockerapi.container'] = 'container.lua';
            ['dockerapi.network'] = 'network.lua';
            ['dockerapi.node'] = 'node.lua';
            ['dockerapi.service'] = 'service.lua';
            ['dockerapi.swarm'] = 'swarm.lua';
            ['dockerapi.tasks'] = 'tasks.lua';
            ['dockerapi.utils'] = 'utils.lua';
        }
    }
}
-- vim: syntax=lua ts=4 sts=4 sw=4 et
