package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	fmt.Println("🔍 Checking for Zsh...")

	// Check if Zsh is installed
	if !commandExists("zsh") {
		fmt.Println("📥 Installing Zsh...")
		runCommand("sudo", "apt", "update")
		runCommand("sudo", "apt", "install", "-y", "zsh")
	} else {
		fmt.Println("✅ Zsh is already installed!")
	}

	// Check default shell
	fmt.Println("🔍 Checking default shell...")
	currentShell := getCurrentShell()
	if !strings.Contains(currentShell, "zsh") {
		fmt.Println("🔄 Changing default shell to Zsh...")
		runCommand("chsh", "-s", "/bin/zsh")
		fmt.Println("ℹ️ Please log out and log back in for the shell change to take effect.")
	} else {
		fmt.Println("✅ Zsh is already the default shell!")
	}

	// Check if Oh My Zsh is installed
	fmt.Println("🔍 Checking for Oh My Zsh...")
	if _, err := os.Stat(os.Getenv("HOME") + "/.oh-my-zsh"); os.IsNotExist(err) {
		fmt.Println("📥 Installing Oh My Zsh...")
		runCommand("sh", "-c", `$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)`)
	} else {
		fmt.Println("✅ Oh My Zsh is already installed!")
	}

	// Define Zsh custom plugins path
	zshCustom := os.Getenv("HOME") + "/.oh-my-zsh/custom"

	// Install plugins if not present
	plugins := map[string]string{
		"zsh-autosuggestions":     "https://github.com/zsh-users/zsh-autosuggestions",
		"zsh-syntax-highlighting": "https://github.com/zsh-users/zsh-syntax-highlighting",
	}

	fmt.Println("🔍 Checking for plugins...")
	for plugin, repo := range plugins {
		pluginPath := zshCustom + "/plugins/" + plugin
		if _, err := os.Stat(pluginPath); os.IsNotExist(err) {
			fmt.Printf("📥 Installing %s...\n", plugin)
			runCommand("git", "clone", repo, pluginPath)
		} else {
			fmt.Printf("✅ %s is already installed!\n", plugin)
		}
	}

	// Update .zshrc
	fmt.Println("🎨 Setting theme to 'fino'...")
	runCommand("sed", "-i", `s/^ZSH_THEME=".*"/ZSH_THEME="fino"/g`, os.Getenv("HOME")+"/.zshrc")

	fmt.Println("🔧 Updating plugins in .zshrc...")
	runCommand("sed", "-i", `s/^plugins=(.*)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting kubectl)/g`, os.Getenv("HOME")+"/.zshrc")

	// Completion message
	fmt.Println("🎉 Setup complete! Restart your terminal or log out and log back in for full effect 🚀")
}

// commandExists checks if a command exists in the system
func commandExists(cmd string) bool {
	_, err := exec.LookPath(cmd)
	return err == nil
}

// getCurrentShell retrieves the user's current shell
func getCurrentShell() string {
	shell := os.Getenv("SHELL")
	if shell == "" {
		shell = "/bin/bash" // Default to Bash if not set
	}
	return shell
}

// runCommand executes a shell command
func runCommand(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()
	if err != nil {
		fmt.Printf("❌ Error running command: %s %v\n", name, args)
		os.Exit(1)
	}
}
