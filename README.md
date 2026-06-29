# Linux Kernel & Performance Profiling

*🌍 [English](#english) | 🇷🇺 [Русский](#russian)*

---

<h2 id="english">🇬🇧 English</h2>

Experiments and benchmarks focusing on Linux kernel subsystems.

*   **⚙️ I/O Scheduler Modification:** Modified the `write_expire` constant in the Linux Kernel (`mq-deadline.c`) and proved the shift in I/O starvation boundaries using a custom Direct I/O stress-test.
*   **🧠 Memory Allocators Benchmark:** Hooked allocators via `LD_PRELOAD` to compare `glibc malloc` vs `tcmalloc`.
*   **💻 CPU Scheduler & Affinity:** Analyzed the `CFS` scheduler. Used `taskset` to actively isolate cores and observe hardware optimizations like Intel Turbo Boost.
*   **💽 Filesystem Benchmarks:** Performance testing of ext4, xfs, btrfs, f2fs, and conceptual profiling of the `piFS` (storing data in Pi digits).

---

<h2 id="russian">🇷🇺 Русский</h2>

Стресс-тесты и профилирование подсистем ядра Linux.

*   **⚙️ Модификация планировщика ввода-вывода:** Изменение константы `write_expire` в исходном коде ядра Linux (`mq-deadline.c`) и тестирование через Direct I/O.
*   **🧠 Бенчмарк аллокаторов памяти:** Сравнение `glibc malloc` и `tcmalloc` с использованием `LD_PRELOAD`.
*   **💻 Планировщик CPU и Affinity:** Анализ `CFS`. Использование `taskset` для изоляции ядер и наблюдения за аппаратным ускорением (Intel Turbo Boost).
*   **💽 Бенчмарк файловых систем:** Тестирование производительности ext4, xfs, btrfs, f2fs и концептуальной `piFS`.
