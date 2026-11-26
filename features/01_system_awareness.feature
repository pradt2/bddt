Feature: Understand the machine's current condition

  A user needs to diagnose resource pressure without modifying the machine.

  Scenario: Determine whether the CPU is saturated
    Given the following private system fixture:
      """
      {
        "system": {
          "cpu_busy_percent_by_logical_cpu": [
            94,
            98,
            92,
            96
          ]
        }
      }
      """
    And the user is given the following task brief:
      """
      The machine feels slow. Report mean CPU utilisation, which logical CPUs are below 20% busy, and whether the mean is at least 90% (our saturation threshold). CPU numbering starts at zero.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "mean_cpu_busy_percent": 95,
          "substantially_idle_cpus": [],
          "cpu_saturated": true
        },
        "process_effects": []
      }
      """

  Scenario: Distinguish one busy logical CPU from machine-wide saturation
    Given the following private system fixture:
      """
      {
        "system": {
          "cpu_busy_percent_by_logical_cpu": [
            8,
            96,
            12,
            4
          ]
        }
      }
      """
    And the user is given the following task brief:
      """
      A workload is making poor progress. Find the most heavily utilised logical CPU and compare that with whole-machine utilisation. Logical CPU numbering starts at zero.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "busiest_cpu": 1,
          "busiest_cpu_busy_percent": 96,
          "mean_cpu_busy_percent": 30
        },
        "process_effects": []
      }
      """

  Scenario: Understand physical memory and swap usage separately
    Given the following private system fixture:
      """
      {
        "system": {
          "ram_total_mib": 16384,
          "ram_used_mib": 11264,
          "ram_cache_mib": 3072,
          "swap_total_mib": 4096,
          "swap_used_mib": 768
        }
      }
      """
    And the user is given the following task brief:
      """
      Report total physical RAM, RAM in use excluding reclaimable file cache, the cache itself, and swap used out of its capacity. Use MiB.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "ram_total_mib": 16384,
          "ram_used_mib": 11264,
          "ram_cache_mib": 3072,
          "swap_total_mib": 4096,
          "swap_used_mib": 768
        },
        "process_effects": []
      }
      """

  Scenario: Recognise a machine with no configured swap
    Given the following private system fixture:
      """
      {
        "system": {
          "ram_total_mib": 8192,
          "ram_used_mib": 7040,
          "swap_total_mib": 0,
          "swap_used_mib": 0
        }
      }
      """
    And the user is given the following task brief:
      """
      Find out whether swap exists, not merely whether it is currently unused.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "swap_configured": false,
          "swap_total_mib": 0
        },
        "process_effects": []
      }
      """

  Scenario: Report load average and uptime
    Given the following private system fixture:
      """
      {
        "system": {
          "load_average_1_5_15_min": [
            3.25,
            1.8,
            0.9
          ],
          "uptime_seconds": 90000
        }
      }
      """
    And the user is given the following task brief:
      """
      Report load averages for the last 1, 5 and 15 minutes, and uptime in hours and minutes.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "load_average_1_5_15_min": [
            3.25,
            1.8,
            0.9
          ],
          "uptime_hours": 25,
          "uptime_minutes": 0
        },
        "process_effects": []
      }
      """

  Scenario: Distinguish running tasks from all tasks
    Given the following private system fixture:
      """
      {
        "system": {
          "process_count": 4,
          "user_thread_count": 3,
          "kernel_thread_count": 2,
          "running_task_count": 2
        }
      }
      """
    And the user is given the following task brief:
      """
      Find the reported number of processes, additional user and kernel threads, and tasks currently running. Do not confuse a running count with total count.
      """
    When the user attempts the task
    Then the independent evaluator must observe:
      """
      {
        "outcome": {
          "process_count": 4,
          "user_thread_count": 3,
          "kernel_thread_count": 2,
          "running_task_count": 2
        },
        "process_effects": []
      }
      """
