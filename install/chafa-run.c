#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <sys/wait.h>

// Store original terminal state globally so signal handler can restore it
static struct termios original_termios;
static pid_t child_pid = -1;

// Called if chafa-run itself receives a signal (e.g. user kills it externally)
// Restores terminal and kills child before exiting
void cleanup(int sig) {
    tcsetattr(STDIN_FILENO, TCSADRAIN, &original_termios);
    if (child_pid > 0) {
        kill(child_pid, SIGTERM);
        waitpid(child_pid, NULL, 0);
    }
    exit(0);
}

int main(int argc, char *argv[]) {
    // argv[0] is "chafa-run", argv[1..] are the args to pass to chafa
    // Build chafa argument list: ["chafa", argv[1], argv[2], ..., NULL]
    if (argc < 2) {
        fprintf(stderr, "Usage: chafa-run <chafa args...>\n");
        return 1;
    }

    // Save current terminal state before we touch anything
    tcgetattr(STDIN_FILENO, &original_termios);

    // Register cleanup handler for common signals so terminal is always restored
    signal(SIGINT,  cleanup);
    signal(SIGTERM, cleanup);
    signal(SIGHUP,  cleanup);

    // Fork — after this line, two identical processes are running
    child_pid = fork();

    if (child_pid < 0) {
        // fork() failed — extremely rare, means OS is out of resources
        perror("fork failed");
        return 1;
    }

    if (child_pid == 0) {
        // We are the CHILD process
        // Replace this process entirely with chafa
        // argv+1 skips "chafa-run" and passes remaining args directly to chafa
        execvp("chafa", argv + 1);
        // If execvp returns, it failed (chafa not found etc.)
        perror("execvp failed");
        exit(1);
    }

    // We are the PARENT process
    // Child (chafa) is now running with full TTY access and animating

    // Set terminal to raw mode so any single keypress is detected immediately
    // without waiting for Enter
    struct termios raw = original_termios;
    raw.c_lflag &= ~(ICANON | ECHO); // disable line buffering and echo
    raw.c_cc[VMIN]  = 1;             // read() returns after 1 byte
    raw.c_cc[VTIME] = 0;             // no timeout — wait forever
    tcsetattr(STDIN_FILENO, TCSADRAIN, &raw);
    
    // Give chafa time to start up and flush its escape sequences
    usleep(200000); // 200ms

    // Drain any buffered input from chafa's startup
    tcflush(STDIN_FILENO, TCIFLUSH);

    // Block here until user presses any key
    char c;
    read(STDIN_FILENO, &c, 1);

    // Keypress detected — restore terminal immediately
    tcsetattr(STDIN_FILENO, TCSADRAIN, &original_termios);

    // Kill chafa
    kill(child_pid, SIGTERM);

    // Wait for child to fully exit — prevents zombie process
    waitpid(child_pid, NULL, 0);

    return 0;
}
