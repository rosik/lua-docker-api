package = 'dockerapi'
version = 'scm-1'
source  = {
    url    = 'https://github.com/rosik/tarantool-docker-api.git';
    branch = 'master';
}
description = {
    summary  = "Tarantool + Docker = ❤";
    homepage = 'https://github.com/rosik/tarantool-docker-api';
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
            ['dockerapi.init'] =       'init.lua';
            ['dockerapi.containers'] = 'containers.lua';
            ['dockerapi.networks'] =   'networks.lua';
            ['dockerapi.swarm'] =      'swarm.lua';
            ['dockerapi.nodes'] =      'nodes.lua';
            ['dockerapi.services'] =   'services.lua';
            ['dockerapi.tasks'] =      'tasks.lua';
            ['dockerapi.utils'] =      'utils.lua';
        }
    }
}
-- vim: syntax=lua ts=4 sts=4 sw=4 et
