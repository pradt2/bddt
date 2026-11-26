Feature: Find and compare processes

  The process of interest is not necessarily known by PID. Values and identifying clues are available only through the task brief and observations.

  Scenario: Find the CPU bottleneck without knowing its name
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 311,
            "command": "browser",
            "user": "alex",
            "cpu_percent": 12
          },
          {
            "pid": 572,
            "command": "encoder",
            "user": "alex",
            "cpu_percent": 87
          },
          {
            "pid": 146,
            "command": "sync",
            "user": "alex",
            "cpu_percent": 44
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Find which process is consuming the most CPU right now. Report its command, PID and CPU percentage.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 572,
          "command": "encoder",
          "cpu_percent": 87
        },
        "process_effects": []
      }
      """

  Scenario: Identify the largest resident-memory consumer
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 611,
            "command": "runtime",
            "user": "alex",
            "rss_mib": 700,
            "virtual_mib": 12000
          },
          {
            "pid": 340,
            "command": "editor",
            "user": "alex",
            "rss_mib": 2100,
            "virtual_mib": 4800
          },
          {
            "pid": 890,
            "command": "browser",
            "user": "alex",
            "rss_mib": 1200,
            "virtual_mib": 6500
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Determine which process occupies the most resident physical memory, rather than which has the largest virtual address space. Report PID and resident MiB.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 340,
          "rss_mib": 2100
        },
        "process_effects": []
      }
      """

  Scenario: Rank processes from highest to lowest CPU usage
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 56,
            "command": "a",
            "user": "alex",
            "cpu_percent": 19
          },
          {
            "pid": 89,
            "command": "b",
            "user": "alex",
            "cpu_percent": 2
          },
          {
            "pid": 12,
            "command": "c",
            "user": "alex",
            "cpu_percent": 71
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Report all processes in descending order of current CPU usage.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "ordered_pids": [
            12,
            56,
            89
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Rank processes from lowest to highest CPU usage
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 56,
            "command": "a",
            "user": "alex",
            "cpu_percent": 19
          },
          {
            "pid": 89,
            "command": "b",
            "user": "alex",
            "cpu_percent": 2
          },
          {
            "pid": 12,
            "command": "c",
            "user": "alex",
            "cpu_percent": 71
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Report all processes in ascending order of current CPU usage.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "ordered_pids": [
            89,
            56,
            12
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Identify the process with greatest accumulated CPU time
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 1,
            "command": "service",
            "user": "alex",
            "cpu_percent": 2,
            "cpu_time_seconds": 804
          },
          {
            "pid": 8,
            "command": "build",
            "user": "alex",
            "cpu_percent": 88,
            "cpu_time_seconds": 31
          },
          {
            "pid": 15,
            "command": "sync",
            "user": "alex",
            "cpu_percent": 5,
            "cpu_time_seconds": 91
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Which process has accumulated the most processor time over its lifetime? Report PID and accumulated CPU seconds, not instantaneous usage.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 1,
          "cpu_time_seconds": 804
        },
        "process_effects": []
      }
      """

  Scenario: Identify a process from a supplied PID
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 71,
            "command": "/usr/bin/python worker.py",
            "user": "alex"
          },
          {
            "pid": 807,
            "command": "/usr/bin/backup --daily",
            "user": "sam"
          },
          {
            "pid": 109,
            "command": "/usr/bin/browser",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      An alert from another system names PID 807. Identify its owner and full command.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 807,
          "user": "sam",
          "command": "/usr/bin/backup --daily"
        },
        "process_effects": []
      }
      """

  Scenario: Find all commands matching a known fragment
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 90,
            "command": "python train.py --worker 1",
            "user": "alex"
          },
          {
            "pid": 41,
            "command": "python unrelated.py",
            "user": "alex"
          },
          {
            "pid": 76,
            "command": "python train.py --worker 2",
            "user": "alex"
          },
          {
            "pid": 55,
            "command": "editor",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      You know the job's command contains the text train.py. Identify every matching PID.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "matching_pids": [
            76,
            90
          ]
        },
        "process_effects": []
      }
      """

  @extended
  Scenario: Find the literal command fragment case-insensitively
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 14,
            "command": "/opt/Build.Worker --id 1",
            "user": "alex"
          },
          {
            "pid": 22,
            "command": "/opt/build.worker --id 2",
            "user": "alex"
          },
          {
            "pid": 35,
            "command": "/opt/buildXworker",
            "user": "alex"
          },
          {
            "pid": 47,
            "command": "editor",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Find processes whose commands contain the literal fragment build.worker, ignoring letter case. The dot is a literal dot.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "matching_pids": [
            14,
            22
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Focus on another user's workload
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 98,
            "command": "build",
            "user": "alex"
          },
          {
            "pid": 40,
            "command": "backup",
            "user": "sam"
          },
          {
            "pid": 73,
            "command": "editor",
            "user": "sam"
          },
          {
            "pid": 22,
            "command": "daemon",
            "user": "root"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Investigate only sam's workload. Make it possible to examine all and only sam's processes; do not terminate or change any processes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "focused_pids": [
            40,
            73
          ]
        },
        "process_effects": []
      }
      """

  Scenario: Find the most demanding process belonging to a particular user
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 5,
            "command": "build",
            "user": "alex",
            "cpu_percent": 99
          },
          {
            "pid": 73,
            "command": "build",
            "user": "sam",
            "cpu_percent": 34
          },
          {
            "pid": 17,
            "command": "encoder",
            "user": "sam",
            "cpu_percent": 76
          },
          {
            "pid": 20,
            "command": "browser",
            "user": "alex",
            "cpu_percent": 11
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Find the highest-CPU process owned by sam. The user's identity is the only clue.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "pid": 17,
          "user": "sam",
          "cpu_percent": 76
        },
        "process_effects": []
      }
      """

  Scenario: Distinguish no match from an empty machine
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 21,
            "command": "editor",
            "user": "alex"
          },
          {
            "pid": 45,
            "command": "backup",
            "user": "alex"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      Determine whether any command contains the fragment ghost-worker. Confirm that other processes still exist even if the sought job doesn't.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "matching_pids": [],
          "other_processes_exist": true
        },
        "process_effects": []
      }
      """

  Scenario: Return to the full machine after a focused investigation
    Given the following private system fixture:
      """
      {
        "processes": [
          {
            "pid": 11,
            "command": "worker",
            "user": "alex"
          },
          {
            "pid": 28,
            "command": "worker",
            "user": "sam"
          },
          {
            "pid": 33,
            "command": "editor",
            "user": "alex"
          },
          {
            "pid": 44,
            "command": "daemon",
            "user": "root"
          }
        ]
      }
      """
    And the user is given the following task brief:
      """
      First examine only sam's workload. Afterwards return to a view of the entire machine without forgetting or altering the other processes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "first_scope_pids": [
            28
          ],
          "final_scope_pids": [
            11,
            28,
            33,
            44
          ]
        },
        "process_effects": []
      }
      """
