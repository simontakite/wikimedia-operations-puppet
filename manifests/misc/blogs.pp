# Wikimedia Blogs

# https://blog.wikimedia.org/
class misc::blogs::wikimedia {
	system_role { "misc::blogs::wikimedia": description => "blog.wikimedia.org" }

	require apaches::packages,
		webserver::php5-gd
		
	package { "unzip":
		ensure => latest;
	}
	
	file {
		"/etc/apache2/sites-available/blog.wikimedia.org":
			path => "/etc/apache2/sites-available/blog.wikimedia.org",
			mode => 0444,
			owner => root,
			group => root,
			source => "puppet:///files/apache/sites/blog.wikimedia.org";
	}
}

