Feature: Investigate when operating-system information is unavailable

  Optional Linux capabilities and external helpers are distinct from the goals they may support.

  @extended @edge
  Scenario: Distinguish unavailable file information from a process with no open files
    Given the following private system fixture:
      """
      {
        "capabilities": {
          "lsof": false
        },
        "processes": [
          {
            "pid": 17,
            "command": "logger",
            "user": "alex",
            "open_files": [
              "/tmp/log.txt"
            ]
          },
          {
            "pid": 18,
            "command": "editor",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Investigate PID 17's open files. If the system lacks the required support, establish that the information is unavailable rather than conclude that the process has no open files.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 17,
          "open_file_information": "unavailable"
        },
        "process_effects": []
      }
      """

  @extended @edge
  Scenario: Do not interpret inaccessible per-process I/O accounting as zero
    Given the following private system fixture:
      """
      {
        "capabilities": {
          "process_io_accounting": true
        },
        "processes": [
          {
            "pid": 15,
            "command": "service",
            "user": "root",
            "io_access": "denied"
          },
          {
            "pid": 27,
            "command": "editor",
            "user": "alex",
            "read_mib_per_s": 0,
            "write_mib_per_s": 0,
            "io_access": "allowed"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Compare disk activity of PID 15 and PID 27. Distinguish a genuinely observed zero from a value you are not entitled to see.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "io_by_pid": {
            "15": "unavailable",
            "27": {
              "read_mib_per_s": 0,
              "write_mib_per_s": 0
            }
          }
        },
        "process_effects": []
      }
      """
