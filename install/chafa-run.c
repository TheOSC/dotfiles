#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <sys/wait.h>

static struct termios original_termios;
static pid_t child_pid = -1;

void cleanup(int sig) {
    tcsetattr(STDIN_FILENO, TCSADRAIN, &original_termios);
    if (child_pid > 0) {
        kill(child_pid, SIGTERM);
        waitpid(child_pid, NULL, 0);
    }
    exit(0);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: chafa-run <chafa args...>\n");
        return 1;
    }
    tcgetattr(STDIN_FILENO, &original_termios);
    signal(SIGINT,  cleanup);
    signal(SIGTERM, cleanup);
    signal(SIGHUP,  cleanup);
    child_pid = fork();
    if (child_pid < 0) {
        perror("fork failed");
        return 1;
    }
    if (child_pid == 0) {
        execvp("chafa", argv + 1);
        perror("execvp failed");
        exit(1);
    }
    struct termios raw = original_termios;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_cc[VMIN]  = 1;
    raw.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSADRAIN, &raw);
    usleep(200000);
    tcflush(STDIN_FILENO, TCIFLUSH);
    char c;
    read(STDIN_FILENO, &c, 1);
    tcsetattr(STDIN_FILENO, TCSADRAIN, &original_termios);
    kill(child_pid, SIGTERM);
    waitpid(child_pid, NULL, 0);
    write(STDOUT_FILENO, "\033[?25h", 6);
    if (c >= 32 && c < 127) {
        FILE *f = fopen("/tmp/.chafa-key", "w");
        if (f) { fputc(c, f); fclose(f); }
    }
    return 0;
}
