Feature: Adapt the monitoring experience to the user's task

  A monitoring session may prioritise different facts depending on the user's investigation. Preferences must not mutate the monitored processes.

  Scenario: Compare resident memory and accumulated CPU time together
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 80,
            "command": "build",
            "user": "alex",
            "rss_mib": 256,
            "cpu_time_seconds": 88
          },
          {
            "pid": 90,
            "command": "editor",
            "user": "alex",
            "rss_mib": 512,
            "cpu_time_seconds": 12
          }
        ],
        "initial_presentation": {
          "process_fields": [
            "pid",
            "command",
            "cpu_percent"
          ]
        }
      }
      """
    And the user is given the following task brief:
      """
      Set up the monitoring experience so that for each process you can examine PID, command, resident memory and accumulated CPU time together, without needing CPU percentage in the same view.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "jointly_available_process_fields": [
            "pid",
            "command",
            "rss_mib",
            "cpu_time_seconds"
          ],
          "cpu_percent_in_presentation": false,
          "reported_values": {
            "80": {
              "rss_mib": 256,
              "cpu_time_seconds": 88
            },
            "90": {
              "rss_mib": 512,
              "cpu_time_seconds": 12
            }
          }
        },
        "process_effects": []
      }
      """

  Scenario: Prioritise system memory and swap information
    Given the following private system fixture:
      """
      {
        "system": {
          "ram_used_mib": 2048,
          "ram_total_mib": 8192,
          "swap_used_mib": 200,
          "swap_total_mib": 2048
        },
        "initial_presentation": {
          "host_metrics": [
            "cpu"
          ]
        }
      }
      """
    And the user is given the following task brief:
      """
      Configure the monitoring experience so the current memory and swap figures are continuously available together. You need no persistent per-CPU breakdown for this investigation.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "continuously_available_host_metrics": [
            "ram",
            "swap"
          ],
          "persistent_per_cpu_breakdown": false
        },
        "process_effects": []
      }
      """

  Scenario: Keep monitoring preferences across clean restarts
    Given the following private system fixture:
      """
      {
        "initial_presentation": {
          "process_fields": [
            "pid",
            "command",
            "cpu_percent"
          ],
          "host_metrics": [
            "cpu"
          ],
          "refresh_interval_ms": 1000
        },
        "system": {
          "ram_used_mib": 1024,
          "ram_total_mib": 4096
        },
        "processes": [
          {
            "pid": 41,
            "command": "build",
            "user": "alex",
            "rss_mib": 256
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Choose a monitoring configuration featuring PID, command and resident memory, a host-memory readout, and updates every two seconds. Leave normally, then return in a new session under the same account. Recover those preferences without re-entering them.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "restored_process_fields": [
            "pid",
            "command",
            "rss_mib"
          ],
          "restored_host_metrics": [
            "ram"
          ],
          "restored_refresh_interval_ms": 2000
        },
        "process_effects": []
      }
      """

  Scenario: Adjust the monitoring cadence to a slower rate
    Given the following private system fixture:
      """
      {
        "initial_presentation": {
          "refresh_interval_ms": 1000
        },
        "system": {
          "logical_cpus": [
            0,
            1
          ]
        }
      }
      """
    And the user is given the following task brief:
      """
      The display is changing too rapidly for this investigation. Set the update interval to five seconds and establish that the new cadence is in effect.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "refresh_interval_ms": 5000
        },
        "process_effects": []
      }
      """

  Scenario: Begin an investigation with only externally supplied target PIDs
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 98,
            "command": "worker",
            "user": "alex"
          },
          {
            "pid": 77,
            "command": "editor",
            "user": "alex"
          },
          {
            "pid": 69,
            "command": "backup",
            "user": "alex"
          },
          {
            "pid": 56,
            "command": "daemon",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      A job supervisor hands you PIDs 69 and 98 before you start monitoring. Begin the investigation restricted to these two processes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "initial_investigation_pids": [
            69,
            98
          ]
        },
        "process_effects": []
      }
      """

  @constraint
  Scenario: Use the monitoring application in a keyboard-only terminal
    Given the following private system fixture:
      """
      {
        "client_constraints": {
          "keyboard": true,
          "mouse": false,
          "terminal_columns": 80,
          "terminal_rows": 24
        },
        "processes": [
          {
            "pid": 77,
            "command": "service",
            "user": "alex",
            "cpu_percent": 31
          },
          {
            "pid": 88,
            "command": "editor",
            "user": "alex",
            "cpu_percent": 50
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      On a terminal without a mouse, identify the process currently consuming the most CPU. No PID or command is supplied.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "highest_cpu_pid": 88,
          "mouse_used": false
        },
        "process_effects": []
      }
      """

  @extended
  Scenario: Learn the meaning of a reported process state without external documentation
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 31,
            "command": "worker",
            "user": "alex",
            "state": "S"
          }
        ],
        "user_knowledge": {
          "knows_process_state_codes": false
        }
      }
      """
    And the user is given the following task brief:
      """
      Locate the worker and report its PID and execution state. Use information available within the application to explain what that state means; you do not know the state codes in advance.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 31,
          "state": "S",
          "meaning": "sleeping"
        },
        "process_effects": []
      }
      """
