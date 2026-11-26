Feature: Control selected processes without harming others

  Every signal and scheduling change affects a simulated kernel only. The user must identify the target from supplied clues or observations.

  Scenario: Gracefully terminate the verified runaway process
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 21,
            "command": "encode --job primary",
            "user": "alex",
            "cpu_percent": 93
          },
          {
            "pid": 12,
            "command": "encode --job secondary",
            "user": "alex",
            "cpu_percent": 11
          },
          {
            "pid": 33,
            "command": "editor",
            "user": "alex",
            "cpu_percent": 6
          }
        ],
        "signal_responses": {
          "21": {
            "SIGTERM": "exit"
          },
          "12": {
            "SIGTERM": "exit"
          },
          "33": {
            "SIGTERM": "exit"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Stop the encode job with the highest CPU usage using a graceful termination request. Leave the other jobs alone. Its PID is not supplied.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "terminated_pids": [
            21
          ],
          "remaining_pids": [
            12,
            33
          ]
        },
        "process_effects": [
          {
            "pid": 21,
            "signal": "SIGTERM"
          }
        ]
      }
      """

  Scenario: Send a non-terminating signal to pause a specific job
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 70,
            "command": "backup --night",
            "user": "alex"
          },
          {
            "pid": 71,
            "command": "backup --day",
            "user": "alex"
          }
        ],
        "signal_responses": {
          "70": {
            "SIGSTOP": "stopped"
          },
          "71": {
            "SIGSTOP": "stopped"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Temporarily suspend the night backup without ending it or affecting the day backup.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "target_pid": 70,
          "target_present": true,
          "target_state": "stopped",
          "other_pid": 71,
          "other_unchanged": true
        },
        "process_effects": [
          {
            "pid": 70,
            "signal": "SIGSTOP"
          }
        ]
      }
      """

  Scenario: Resume a stopped process
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 70,
            "command": "backup --night",
            "user": "alex",
            "state": "stopped"
          },
          {
            "pid": 71,
            "command": "backup --day",
            "user": "alex",
            "state": "sleeping"
          }
        ],
        "signal_responses": {
          "70": {
            "SIGCONT": "runnable"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Resume the previously suspended night backup. Do not disturb the other backup.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "target_pid": 70,
          "target_state": "runnable",
          "other_unchanged": true
        },
        "process_effects": [
          {
            "pid": 70,
            "signal": "SIGCONT"
          }
        ]
      }
      """

  Scenario: Escalate only after graceful termination proves ineffective
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 12,
            "command": "hung-export",
            "user": "alex"
          },
          {
            "pid": 13,
            "command": "editor",
            "user": "alex"
          }
        ],
        "signal_responses": {
          "12": {
            "SIGTERM": "remains_alive",
            "SIGKILL": "exit"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Try to stop hung-export gracefully. If it remains alive after the next observation, force it to end. Verify the result and leave the editor alone.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "alive_after_graceful_request": true,
          "finally_terminated_pids": [
            12
          ],
          "remaining_pids": [
            13
          ]
        },
        "process_effects": [
          {
            "pid": 12,
            "signal": "SIGTERM"
          },
          {
            "pid": 12,
            "signal": "SIGKILL"
          }
        ]
      }
      """

  Scenario: Terminate multiple matching jobs but not lookalikes
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 71,
            "command": "batch --project demo",
            "user": "alex"
          },
          {
            "pid": 72,
            "command": "batch --project other",
            "user": "alex"
          },
          {
            "pid": 73,
            "command": "batch --project demo",
            "user": "alex"
          },
          {
            "pid": 74,
            "command": "batch --project demo",
            "user": "sam"
          }
        ],
        "signal_responses": {
          "71": {
            "SIGTERM": "exit"
          },
          "72": {
            "SIGTERM": "exit"
          },
          "73": {
            "SIGTERM": "exit"
          },
          "74": {
            "SIGTERM": "denied"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Gracefully terminate all of your own batch jobs for project demo. Leave other projects and other users' jobs alone. You know your account is alex, but no target PIDs.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "terminated_pids": [
            71,
            73
          ],
          "remaining_pids": [
            72,
            74
          ]
        },
        "process_effects": [
          {
            "pid": 71,
            "signal": "SIGTERM"
          },
          {
            "pid": 73,
            "signal": "SIGTERM"
          }
        ]
      }
      """

  Scenario: Lower a job's CPU scheduling priority
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex",
          "may_increase_own_nice": true
        },
        "processes": [
          {
            "pid": 91,
            "command": "background-render",
            "user": "alex",
            "nice": 0
          },
          {
            "pid": 92,
            "command": "interactive-editor",
            "user": "alex",
            "nice": 0
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Make background-render less favoured by the CPU scheduler by giving it a nice value of 5. Leave the editor's priority unchanged.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "nice_by_pid": {
            "91": 5,
            "92": 0
          }
        },
        "process_effects": [
          {
            "pid": 91,
            "nice_final": 5
          }
        ]
      }
      """

  Scenario: Raise a job's CPU scheduling priority when authorised
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "admin",
          "may_decrease_nice": true
        },
        "processes": [
          {
            "pid": 39,
            "command": "latency-sensitive-job",
            "user": "alex",
            "nice": 5
          },
          {
            "pid": 40,
            "command": "archive",
            "user": "alex",
            "nice": 0
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Restore latency-sensitive-job to a nice value of 0. You are authorised to do so. Do not change the archive process.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "nice_by_pid": {
            "39": 0,
            "40": 0
          }
        },
        "process_effects": [
          {
            "pid": 39,
            "nice_final": 0
          }
        ]
      }
      """

  @edge
  Scenario: Avoid claiming success for a denied scheduling change
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex",
          "may_decrease_nice": false
        },
        "processes": [
          {
            "pid": 60,
            "command": "compile",
            "user": "alex",
            "nice": 5
          },
          {
            "pid": 61,
            "command": "editor",
            "user": "alex",
            "nice": 0
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Try to increase compile's scheduling priority to nice 0. Determine whether that request actually succeeds.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "requested_change_succeeded": false,
          "nice_by_pid": {
            "60": 5,
            "61": 0
          }
        },
        "process_effects": []
      }
      """

  Scenario: Set and verify CPU affinity
    Given the following private system fixture:
      """
      {
        "system": {
          "logical_cpus": [
            0,
            1,
            2,
            3
          ]
        },
        "actor": {
          "user": "alex",
          "may_set_own_affinity": true
        },
        "processes": [
          {
            "pid": 99,
            "command": "test-worker",
            "user": "alex",
            "affinity": [
              0,
              1,
              2,
              3
            ]
          },
          {
            "pid": 98,
            "command": "editor",
            "user": "alex",
            "affinity": [
              0,
              1,
              2,
              3
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Restrict test-worker to logical CPUs 1 and 3 only, and verify its resulting allowed CPU set. Do not alter other processes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "affinity_by_pid": {
            "98": [
              0,
              1,
              2,
              3
            ],
            "99": [
              1,
              3
            ]
          }
        },
        "process_effects": [
          {
            "pid": 99,
            "affinity_final": [
              1,
              3
            ]
          }
        ]
      }
      """

  @edge
  Scenario: Do not claim a signal succeeded when permissions deny it
    Given the following private system fixture:
      """
      {
        "actor": {
          "user": "alex",
          "may_signal_other_users": false
        },
        "processes": [
          {
            "pid": 21,
            "command": "service --root",
            "user": "root"
          },
          {
            "pid": 30,
            "command": "editor",
            "user": "alex"
          }
        ],
        "signal_responses": {
          "21": {
            "SIGTERM": "denied"
          }
        }
      }
      """
    And the user is given the following task brief:
      """
      Try to request graceful termination of service --root and establish whether the request was successful. You are an ordinary unprivileged user.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "requested_signal_succeeded": false,
          "target_pid": 21,
          "target_present": true,
          "remaining_pids": [
            21,
            30
          ]
        },
        "process_effects": []
      }
      """

  @edge
  Scenario: Read-only investigation cannot change a process
    Given the following private system fixture:
      """
      {
        "session": {
          "read_only": true
        },
        "actor": {
          "user": "alex"
        },
        "processes": [
          {
            "pid": 55,
            "command": "render",
            "user": "alex",
            "nice": 0,
            "affinity": [
              0,
              1
            ]
          },
          {
            "pid": 56,
            "command": "editor",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      You are investigating a machine in a session deliberately restricted to observation. Identify render, and establish whether you can terminate it or change its nice value. Inspection must remain possible.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "identified_pid": 55,
          "termination_available": false,
          "scheduling_change_available": false,
          "remaining_pids": [
            55,
            56
          ]
        },
        "process_effects": []
      }
      """

  @edge
  Scenario: Do not redirect a process-control request to an unrelated job
    Given the following private system fixture:
      """
      {
        "samples": [
          {
            "time_s": 0,
            "processes": [
              {
                "pid": 31,
                "command": "build",
                "user": "alex",
                "cpu_percent": 95
              },
              {
                "pid": 52,
                "command": "editor",
                "user": "alex",
                "cpu_percent": 10
              }
            ]
          },
          {
            "time_s": 1,
            "processes": [
              {
                "pid": 52,
                "command": "editor",
                "user": "alex",
                "cpu_percent": 95
              }
            ]
          }
        ],
        "event": "build exits externally after first observation, before intended termination request",
        "actor": {
          "user": "alex"
        }
      }
      """
    And the user is given the following task brief:
      """
      Identify build at the first observation. Before you finish requesting graceful termination, the system updates. Check whether the intended process still exists. Never send a signal to whichever process happens to replace it in the display.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "intended_pid": 31,
          "already_gone": true,
          "remaining_pids": [
            52
          ]
        },
        "process_effects": []
      }
      """
