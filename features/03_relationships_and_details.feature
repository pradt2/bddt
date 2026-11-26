Feature: Understand process identity, ancestry and details

  A process name alone is often insufficient to attribute work to the correct program or service.

  Scenario: Read a long command without losing its identity
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 101,
            "command": "/usr/bin/python /srv/tasks/run.py --name morning --output /var/tmp/results/morning-long.json",
            "user": "alex"
          },
          {
            "pid": 102,
            "command": "/usr/bin/python /srv/tasks/run.py --name evening --output /var/tmp/results/evening-long.json",
            "user": "alex"
          }
        ],
        "client_constraints": {
          "terminal_columns": 48,
          "terminal_rows": 12
        }
      }
      """
    And the user is given the following task brief:
      """
      An external job report identifies PID 102. Find its complete command including the output filename using a narrow terminal. The full command isn't supplied to you.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 102,
          "command": "/usr/bin/python /srv/tasks/run.py --name evening --output /var/tmp/results/evening-long.json"
        },
        "process_effects": []
      }
      """

  Scenario: Determine which worker belongs to which supervisor
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 1,
            "command": "init",
            "user": "alex",
            "ppid": 0
          },
          {
            "pid": 70,
            "command": "supervisor-a",
            "user": "alex",
            "ppid": 1
          },
          {
            "pid": 71,
            "command": "supervisor-b",
            "user": "alex",
            "ppid": 1
          },
          {
            "pid": 80,
            "command": "worker",
            "user": "alex",
            "ppid": 70
          },
          {
            "pid": 81,
            "command": "worker",
            "user": "alex",
            "ppid": 71
          },
          {
            "pid": 82,
            "command": "helper",
            "user": "alex",
            "ppid": 80
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Two supervisors start similarly named workers. Report the lineage from init to PID 82 inclusive, and the PID of the supervisor of the worker outside that lineage.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "ancestry_pid_82": [
            1,
            70,
            80,
            82
          ],
          "parent_pid_81": 71
        },
        "process_effects": []
      }
      """

  Scenario: Reduce clutter from a large process family and inspect it again
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 10,
            "command": "scheduler",
            "user": "alex",
            "ppid": 1
          },
          {
            "pid": 21,
            "command": "worker",
            "user": "alex",
            "ppid": 10
          },
          {
            "pid": 22,
            "command": "worker",
            "user": "alex",
            "ppid": 10
          },
          {
            "pid": 23,
            "command": "helper",
            "user": "alex",
            "ppid": 21
          },
          {
            "pid": 31,
            "command": "editor",
            "user": "alex",
            "ppid": 1
          },
          {
            "pid": 1,
            "command": "init",
            "user": "alex",
            "ppid": 0
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Reduce the displayed detail for the scheduler's descendants while keeping the scheduler and unrelated editor accessible. Later inspect the same descendants again without ending any processes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "descendants_hidden": [
            21,
            22,
            23
          ],
          "visible_during_reduction": [
            1,
            10,
            31
          ],
          "descendants_recovered": [
            21,
            22,
            23
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Distinguish independent processes from their user-space threads
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 10,
            "command": "renderer",
            "user": "alex",
            "kind": "process"
          },
          {
            "pid": 11,
            "command": "renderer",
            "user": "alex",
            "kind": "user_thread",
            "thread_group_pid": 10
          },
          {
            "pid": 12,
            "command": "renderer",
            "user": "alex",
            "kind": "user_thread",
            "thread_group_pid": 10
          },
          {
            "pid": 20,
            "command": "browser",
            "user": "alex",
            "kind": "process"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Investigate the independent applications without separate worker-thread entries. Then recover the individual user-space thread identities.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "process_only_pids": [
            10,
            20
          ],
          "recovered_thread_ids": [
            11,
            12
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Exclude kernel threads from a user-space investigation
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 2,
            "command": "kthreadd",
            "user": "root",
            "kind": "kernel_thread"
          },
          {
            "pid": 13,
            "command": "kworker",
            "user": "root",
            "kind": "kernel_thread"
          },
          {
            "pid": 41,
            "command": "editor",
            "user": "alex",
            "kind": "process"
          },
          {
            "pid": 42,
            "command": "compiler",
            "user": "alex",
            "kind": "process"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Concentrate on user-space processes; identify the remaining PIDs. Kernel workers must not obscure this investigation.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "focused_pids": [
            41,
            42
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Find current process state and owner
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 31,
            "command": "build",
            "user": "sam",
            "state": "R",
            "nice": 0
          },
          {
            "pid": 42,
            "command": "backup",
            "user": "alex",
            "state": "S",
            "nice": 5
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      The job supervisor reports PID 42. Find its owner, current execution state and scheduling nice value.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 42,
          "user": "alex",
          "state": "S",
          "nice": 5
        },
        "process_effects": []
      }
      """

  @extended
  Scenario: Look up readable environment data of one process
    Given the following private system fixture:
      """
      {
        "capabilities": {
          "process_environment": true
        },
        "processes": [
          {
            "pid": 51,
            "command": "service",
            "user": "alex",
            "environment": {
              "APP_MODE": "staging",
              "LANG": "en_GB.UTF-8"
            }
          },
          {
            "pid": 52,
            "command": "service",
            "user": "alex",
            "environment": {
              "APP_MODE": "prod"
            }
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      The test service is PID 51. Determine the value of its APP_MODE environment variable. The value is not known to you in advance.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 51,
          "APP_MODE": "staging"
        },
        "process_effects": []
      }
      """

  @extended
  Scenario: Identify open files of a known process
    Given the following private system fixture:
      """
      {
        "capabilities": {
          "lsof": true
        },
        "processes": [
          {
            "pid": 76,
            "command": "logger",
            "user": "alex",
            "open_files": [
              "/tmp/activity.log",
              "/tmp/state.db"
            ]
          },
          {
            "pid": 77,
            "command": "logger",
            "user": "alex",
            "open_files": [
              "/tmp/other.log"
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      The logger under investigation is PID 76. Find which two files it currently has open, not files of the other logger.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 76,
          "open_files": [
            "/tmp/activity.log",
            "/tmp/state.db"
          ]
        },
        "process_effects": []
      }
      """

  @extended
  Scenario: Identify disk-I/O-heavy process rather than CPU-heavy process
    Given the following private system fixture:
      """
      {
        "capabilities": {
          "process_io_accounting": true
        },
        "processes": [
          {
            "pid": 13,
            "command": "compute",
            "user": "alex",
            "cpu_percent": 90,
            "read_mib_per_s": 1,
            "write_mib_per_s": 0
          },
          {
            "pid": 27,
            "command": "backup",
            "user": "alex",
            "cpu_percent": 3,
            "read_mib_per_s": 20,
            "write_mib_per_s": 45
          },
          {
            "pid": 34,
            "command": "editor",
            "user": "alex",
            "cpu_percent": 12,
            "read_mib_per_s": 0,
            "write_mib_per_s": 2
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      The disk is busy. Identify the process with the greatest total disk read/write throughput and report its separate rates in MiB/s.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 27,
          "read_mib_per_s": 20,
          "write_mib_per_s": 45
        },
        "process_effects": []
      }
      """
