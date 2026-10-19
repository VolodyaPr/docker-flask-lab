# Отчет:

## Ссылка на Docker Hub: https://hub.docker.com/r/volodyapr/image-lab2/tags

## docker history

Вывод: docker history volodyapr/image-lab2:dc6a169b

```text
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
cacf8567da9c   31 minutes ago   CMD ["python" "app/app.py"]                     0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   ENTRYPOINT ["dumb-init" "--"]                   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   HEALTHCHECK &{["CMD-SHELL" "python -c \"impo…   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   EXPOSE map[8000/tcp:{}]                         0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   USER appuser                                    0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFER…   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   COPY --chown=appuser:appgroup app/ ./app/ # …   16.4kB    buildkit.dockerfile.v0
<missing>      31 minutes ago   ENV PATH=/opt/venv/bin:/usr/local/bin:/usr/l…   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   COPY /opt/venv /opt/venv # buildkit             35.2MB    buildkit.dockerfile.v0
<missing>      31 minutes ago   WORKDIR /app                                    8.19kB    buildkit.dockerfile.v0
<missing>      31 minutes ago   RUN |2 LAB_LOGIN=volodyapr LAB_TOKEN=dc6a169…   41kB      buildkit.dockerfile.v0
<missing>      31 minutes ago   RUN |2 LAB_LOGIN=volodyapr LAB_TOKEN=dc6a169…   3.2MB     buildkit.dockerfile.v0
<missing>      31 minutes ago   LABEL org.lab.login=volodyapr org.lab.token=…   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   ARG LAB_TOKEN=dc6a169bac9787eb57748111fc3121…   0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   ARG LAB_LOGIN=volodyapr                         0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      CMD ["python3"]                                 0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -eux;  for src in idle3 p…   16.4kB    buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -eux;   apk add --no-cach…   57.9MB    buildkit.dockerfile.v0
<missing>      2 weeks ago      ENV PYTHON_SHA256=bfb74ad39efae27cda510f134a…   0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      ENV PYTHON_VERSION=3.11.17                      0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8…   0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -eux;  apk add --no-cache…   2.83MB    buildkit.dockerfile.v0
<missing>      2 weeks ago      ENV LANG=C.UTF-8                                0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      ENV PATH=/usr/local/bin:/usr/local/sbin:/usr…   0B        buildkit.dockerfile.v0
<missing>      4 weeks ago      CMD ["/bin/sh"]                                 0B        buildkit.dockerfile.v0
<missing>      4 weeks ago      ADD alpine-minirootfs-3.24.2-x86_64.tar.gz /…   9.08MB    buildkit.dockerfile.v0
```

##Преимущества
1. **Разделение этапов сборки.**
   Используется два этапа (builder и финальный). В финальный образ копируется только готовое окружение `/opt/venv`. Компиляторы и исходный код зависимостей остаются в первом этапе. Это позволяет образу оставаться в рамкак
   150Мб(в DockerHub около 32Мб).
   ```dockerfile
   COPY --from=builder /opt/venv /opt/venv
   ```
2. **Использование Alpine Linux.**
   Используется образ `python:3.11-alpine`. Именно это позволило сжать образ до 140Мб, при сборке на `python:3.11-slime` выходило около 200Мб в локальном репозитории(46Мб на DockerHub). `Alpine` использует облегченную
   библиотеку `musl libc`. Она быстрее и меньше, но не является стандартом для большинства готовых пакетов.
   ```dockerfile
   FROM python:3.11-alpine
   ```
3. **Запуск от не-root пользователя.**
   Создаётся системный пользователь appuser. С помощью `--chown` сразу назначаем его владельцем файлов приложения, а директивой `USER appuser` переключаем контейнер на работу от этого непривилегированного пользователя.
   Это защищает систему от взлома.
   ```dockerfile
   RUN addgroup -S appgroup && adduser -S appuser -G appgroup
   COPY --chown=appuser:appgroup app/ ./app/
   USER appuser
   ```
4. **Корректное завершение по SIGTERM.**
   Python, запущенный как главный процесс (PID 1), не умеет правильно обрабатывать сигналы завершения (SIGTERM). Поэтому был установлен `dumb-init`, после чего я прописал его в `ENTRYPOINT`. Теперь команда `docker stop`
   будет завершать контейнер мгновенно и корректно, без 10-ти секундной задержки.
   ```dockerfile
   RUN apk add --no-cache dumb-init libstdc++
   ENTRYPOINT ["dumb-init", "--"]
   CMD ["python", "app/app.py"]
   ```
5. **Поддержка режима --read-only.**
   Если запустить контейнер с флагом `--read-only`, файловая система будет доступна только для чтения. По умолчанию Python попытается создать файлы `.pyc` в папке `__pycache__` и упадет с ошибкой. 
   Переменная `PYTHONDONTWRITEBYTECODE=1` отключает создание этих файлов, позволяя контейнеру работать в режиме `--read-only`.
   ```dockerfile
   ENV PYTHONDONTWRITEBYTECODE=1
   ```
6. **Гибкость конфигурации.**
   Переменная `ROCKET_SIZE` задана через ENV со значением по умолчанию. При запуске контейнера можно легко переопределить её,
   и приложение изменит ответ без необходимости пересборки образа.
   ```dockerfile
   ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ROCKET_SIZE=Normal
   ```
7. **Самодиагностика (HEALTHCHECK).**
   Директива `HEALTHCHECK` каждые 30 секунд делает GET-запрос на эндпоинт `/health`. Если сервер перестанет отвечать, Docker переведет контейнер в статус `unhealthy`.
   Это позволяет автоматически перезапускать упавшее приложение.
   ```dockerfile
   HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
   ```

## Правки

   1. **Повторное чтение переменной ROCKET_SIZE при каждом запросе и запуск в read-only**
       <img width="706" height="314" alt="image" src="https://github.com/user-attachments/assets/4f3ebad0-ef8c-49d6-a497-7de2054ce4b8" />

      Изначально я думал что строка `return f"Hello from Docker! Rocket={ROCKET_SIZE}\n"` будет считывать переменную окружения только при сборке образа и решил что нужно добавить дополнительную переменную,
       однако после проверки это оказалось не так и я вернулся к изначальному варианту забыв удалить заготовку для другого варианта. На скриншоте показано что переменная окружения меняется без пересборки образа и что
       контейнер успешно работает в режиме read-only.

   2. **HEALTHCHECK автоматически перезапускает неработающее приложение**

      HEALTHCHECK сам по себе не перезапускает контейнер, он лишь периодически выполняет команду и в случае неудачи меняет статус контейнера с healthy на unhealthy. Сам по себе Docker Engine
       не будет перезапускать контейнер только из-за статуса unhealthy, для перезапуска нужена дополнительная система мониторинга которыя бы отслеживала этот статус и пересоздавала контейнер.
       
   3. **Зачем нужен dumb-init, если есть обработчик SIGTERM**

      В Linux процесс, запущенный с PID 1 имеет особый статус: ядро игнорирует для него обработку сигналов по умолчанию. Если Python запущен напрямую как PID 1 и в нем нет явного обработчика
      SIGTERM, он просто проигнорирует сигнал, и Docker убьет его через 10 секунд.
      Даже если в Python написан обработчик SIGTERM, есть вторая проблема: Python может порождать дочерние процессы, которые не получат сигнал, а dumb-init работает как "менеджер процессов" для
      PID 1. Он перехватывает SIGTERM от Docker и гарантированно передает его Python-приложению.
      Также когда дочерний процесс завершается, он остается в таблице процессов как «зомби», пока родитель не прочитает его код возврата(wait), а Python не всегда делает это автоматически. dumb-init берет на себя роль
      инициатора: он автоматически собирает все завершившиеся дочерние процессы, освобождая PID-ы и предотвращая их утечку, которая может уронить контейнер или хост.
      Хотя в самой работе нет дочерних процессов, но гарантировать что у библиотек этих процессов не будет я не могу.

    
