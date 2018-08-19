AWS CLI role
============

A simple role to configure your instance for a set of users to use aws cli [ could do somthing simlar with IAM roles of course ...]

Requirements
------------

A valid set of:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

And preferably:
* `AWS_REGION`

Usually it will be used via group_vars/all with something like the following:

    aws_region: "{{ lookup('env','AWS_REGION') }}"
    aws_access_key: "{{ lookup('env','AWS_ACCESS_KEY') }}"
    aws_secret_key: "{{ lookup('env','AWS_SECRET_KEY') }}"

Role Variables
--------------

* `aws_cli_user: "{{ common_user | d('root') }}"`
* `aws_cli_group: "{{ common_group | d('root') }}"`
* `aws_output_format: 'json'`
* `aws_region: "{{ aws_region }}"`
* `aws_access_key_id: "{{ aws_access_key }}"`
* `aws_secret_access_key: "{{ aws_secret_key }}"`

Dependencies
------------

None,
But I would recommend using with [shelleg.common](https://github.com/shelleg/ansible-role-common)

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: shelleg.aws_cli

Could be used with `shelleg.common` like so:

    - hosts: servers
      roles:
         - role: shelleg.common
           common_sudoer: false
           common_user: foo
           common_group: bar
           common_home_dir: "/home/{{ * common_user }}"
           common_pubkey: 'asldkjaslkdja...'
         - role: shelleg.aws_cli
           aws_cli_user: "{{ common_user }}"
           aws_cli_group: "{{ common_group }}"


License
-------

[Apache 2](https://choosealicense.com/licenses/apache-2.0/)


Author Information
------------------

[Haggai Philip Zagury](http://www.tikalk.com/devops/haggai)
