Feature: Maintain a useful view as the system changes

  The environment changes independently of the user's interaction. Test time is a deterministic succession of snapshots, not real waiting.

  Scenario: Notice a new resource bottleneck after an update
    Given the following private system fixture:
      """
      {
        "samples": [
          {
            "time_s": 0,
            "processes": [
              {
                "pid": 12,
                "command": "a",
                "user": "alex",
                "cpu_percent": 90
              },
              {
                "pid": 25,
                "command": "b",
                "user": "alex",
                "cpu_percent": 2
              }
            ]
          },
          {
            "time_s": 1,
            "processes": [
              {
                "pid": 12,
                "command": "a",
                "user": "alex",
                "cpu_percent": 5
              },
              {
                "pid": 25,
                "command": "b",
                "user": "alex",
                "cpu_percent": 85
              }
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Identify the highest-CPU process now, remain in the same investigation, then identify the highest-CPU process after the next system update.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "highest_pid_by_sample": [
            12,
            25
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Track the same process despite changing CPU rank
    Given the following private system fixture:
      """
      {
        "samples": [
          {
            "time_s": 0,
            "processes": [
              {
                "pid": 31,
                "command": "compile",
                "user": "alex",
                "cpu_percent": 80
              },
              {
                "pid": 64,
                "command": "render",
                "user": "alex",
                "cpu_percent": 30
              }
            ]
          },
          {
            "time_s": 1,
            "processes": [
              {
                "pid": 31,
                "command": "compile",
                "user": "alex",
                "cpu_percent": 15
              },
              {
                "pid": 64,
                "command": "render",
                "user": "alex",
                "cpu_percent": 95
              }
            ]
          },
          {
            "time_s": 2,
            "processes": [
              {
                "pid": 31,
                "command": "compile",
                "user": "alex",
                "cpu_percent": 70
              },
              {
                "pid": 64,
                "command": "render",
                "user": "alex",
                "cpu_percent": 20
              }
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Follow the compile job identified by its command and record its CPU usage across three successive observations, even when other processes overtake it. You have not been told its PID.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "tracked_pid": 31,
          "cpu_percent_by_sample": [
            80,
            15,
            70
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Observe a new and an exited process
    Given the following private system fixture:
      """
      {
        "samples": [
          {
            "time_s": 0,
            "processes": [
              {
                "pid": 30,
                "command": "worker",
                "user": "alex"
              },
              {
                "pid": 40,
                "command": "editor",
                "user": "alex"
              }
            ]
          },
          {
            "time_s": 1,
            "processes": [
              {
                "pid": 40,
                "command": "editor",
                "user": "alex"
              },
              {
                "pid": 51,
                "command": "backup",
                "user": "alex"
              }
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Observe which processes are present now and after the next update. Identify the process that disappeared and the one that appeared.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "initial_pids": [
            30,
            40
          ],
          "next_pids": [
            40,
            51
          ],
          "disappeared_pid": 30,
          "appeared_pid": 51
        },
        "process_effects": []
      }
      """

  Scenario: Examine a stable snapshot and then return to live information
    Given the following private system fixture:
      """
      {
        "samples": [
          {
            "time_s": 0,
            "processes": [
              {
                "pid": 31,
                "command": "worker",
                "user": "alex",
                "cpu_percent": 91
              }
            ]
          },
          {
            "time_s": 1,
            "processes": [
              {
                "pid": 31,
                "command": "worker",
                "user": "alex",
                "cpu_percent": 14
              },
              {
                "pid": 53,
                "command": "new",
                "user": "alex",
                "cpu_percent": 72
              }
            ]
          },
          {
            "time_s": 2,
            "processes": [
              {
                "pid": 31,
                "command": "worker",
                "user": "alex",
                "cpu_percent": 9
              },
              {
                "pid": 53,
                "command": "new",
                "user": "alex",
                "cpu_percent": 50
              }
            ]
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      At the first observation, hold the process information steady for careful examination through the next update. Then resume live observation and inspect the latest process information.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "held_initial": {
            "pids": [
              31
            ],
            "worker_cpu_percent": 91
          },
          "held_after_update": {
            "pids": [
              31
            ],
            "worker_cpu_percent": 91
          },
          "resumed": {
            "pids": [
              31,
              53
            ],
            "worker_cpu_percent": 9
          }
        },
        "process_effects": []
      }
      """
