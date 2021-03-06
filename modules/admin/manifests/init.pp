# Creates groups, users, and sudo permissions all from yaml for valid passed group name
#
# === Parameters
#
# [*$groups*]
#  Array of valid groups (defined in yaml) to create with associated members
#
# [*$always_groups*]
#  Array of valid groups to always run
#

class admin(
    $groups=[],
    $always_groups=['absent', 'ops', 'wikidev'],
)
{
    include sudo

    $module_path = get_module_path($module_name)
    $data = loadyaml("${module_path}/data/data.yaml")
    $uinfo = $data['users']
    $users = keys($uinfo)

    #making sure to include always_groups
    $all_groups = concat($always_groups, $groups)

    #this custom function eliminates the need for virtual users
    $user_set = unique_users($data, $all_groups)

    file { '/usr/local/sbin/enforce-users-groups':
        ensure => file,
        mode   => '0555',
        source => 'puppet:///modules/admin/enforce-users-groups.sh',
    }

    admin::hashgroup { $all_groups:
        phash  => $data,
        before => Admin::Hashuser[$user_set],
    }

    admin::hashuser { $user_set:
        phash  => $data,
        before => Admin::Groupmembers[$all_groups],
    }

    admin::groupmembers { $all_groups:
        phash  => $data,
        before => Exec['enforce-users-groups-cleanup'],
    }

    # Declarative gotcha: non-defined users can get left behind
    # Here we cleanup anyone not in a supplementary group above a certain UID
    exec { 'enforce-users-groups-cleanup':
        command   => '/usr/local/sbin/enforce-users-groups',
        unless    => '/usr/local/sbin/enforce-users-groups dryrun',
        logoutput => true,
    }
}
