"""
Source Code Collection Utility

Aggregates project source code and file structure into a text file starting
from a specified root path. This utility is useful for documentation, code reviews,
and creating backups of the codebase in a human-readable format.
"""
import os
import argparse
from datetime import datetime
from typing import Optional, List, Any, Dict


def collect_source_code(
    root_path: Optional[str] = None,
    output_file: Optional[str] = None,
    exclude_dirs: Optional[List[str]] = None,
    include_extensions: Optional[List[str]] = None,
    max_file_size_mb: float = 5.0
) -> Dict[str, Any]:
    """
    Collects all source code and file structure into a single text file from a specified root path.

    Args:
        root_path: Starting path for code collection. Defaults to current directory.
        output_file: Name of the output file. Default: 'primevis.txt'.
        exclude_dirs: List of directory names to exclude.
            Defaults to common build/cache directories.
        include_extensions: List of file extensions to include.
            Defaults to common source code file types.
        max_file_size_mb: Maximum file size in MB to include. Defaults to 5MB.

    Returns:
        Dict containing statistics about the collection process:
            - total_files: Number of files processed
            - included_files: Number of files included in the output
            - skipped_files: Number of files skipped (due to size or errors)
            - total_size_mb: Total size of included files in MB
    """
    # Default values
    if exclude_dirs is None:
        exclude_dirs = ['venv', '__pycache__', '.git', 'node_modules', 'dist', 'build', 'logs']

    if include_extensions is None:
        include_extensions = ['.swift','.json','.entitlements']

    if output_file is None:
        output_file = 'primevis.txt'

    # Convert extensions to lowercase for case-insensitive matching
    include_extensions = [ext.lower() for ext in include_extensions]

    # Statistics
    stats = {
        'total_files': 0,
        'included_files': 0,
        'skipped_files': 0,
        'error_files': 0,
        'total_size_mb': 0.0
    }

    project_root = os.path.abspath(root_path if root_path else os.getcwd())
    max_file_size_bytes = max_file_size_mb * 1024 * 1024  # Convert MB to bytes

    with open(output_file, 'w', encoding='utf-8') as outfile:
        # Write header with metadata
        outfile.write(f"# Source Code Collection\n")
        outfile.write(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        outfile.write(f"# Root Path: {project_root}\n")
        outfile.write(f"# Included Extensions: {', '.join(include_extensions)}\n")
        outfile.write(f"# Excluded Directories: {', '.join(exclude_dirs)}\n\n")

        # Write directory structure
        outfile.write("## Project Directory Structure\n\n```\n")
        for dir_path, dirs, files in os.walk(project_root):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in exclude_dirs]

            # Calculate relative path for cleaner output
            rel_path = os.path.relpath(dir_path, project_root)
            if rel_path == '.':
                rel_path = os.path.basename(project_root)

            level = 0 if rel_path == os.path.basename(project_root) else rel_path.count(os.sep)
            indent = ' ' * 2 * level
            outfile.write(f"{indent}{os.path.basename(dir_path)}/\n")

            subindent = ' ' * 2 * (level + 1)
            for file in sorted(files):
                outfile.write(f"{subindent}{file}\n")

        outfile.write("```\n\n")
        outfile.write("## Source Code Files\n\n")

        # Collect source code
        for dir_path, dirs, files in os.walk(project_root):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in exclude_dirs]

            for file in sorted(files):
                stats['total_files'] += 1
                file_ext = os.path.splitext(file)[1].lower()

                if file_ext in include_extensions:
                    filepath = os.path.join(dir_path, file)

                    # Check file size
                    try:
                        file_size = os.path.getsize(filepath)
                        if file_size > max_file_size_bytes:
                            outfile.write(f"### File: {os.path.relpath(filepath, project_root)} (Skipped - Size: {file_size / 1024 / 1024:.2f}MB)\n\n")
                            stats['skipped_files'] += 1
                            continue
                    except OSError as e:
                        outfile.write(f"### File: {os.path.relpath(filepath, project_root)} (Error checking size: {e})\n\n")
                        stats['error_files'] += 1
                        continue

                    # Write file content
                    rel_filepath = os.path.relpath(filepath, project_root)
                    outfile.write(f"### File: {rel_filepath}\n\n```{file_ext[1:] if file_ext else ''}\n")

                    try:
                        with open(filepath, 'r', encoding='utf-8') as f:
                            content = f.read()
                            outfile.write(content)
                            if not content.endswith('\n'):
                                outfile.write('\n')  # Ensure file ends with newline

                            stats['included_files'] += 1
                            stats['total_size_mb'] += file_size / 1024 / 1024
                    except (IOError, PermissionError, UnicodeDecodeError) as e:
                        outfile.write(f"Error reading file: {e}\n")
                        stats['error_files'] += 1

                    outfile.write("```\n\n")

        # Write summary
        outfile.write("## Collection Summary\n\n")
        outfile.write(f"- Total files scanned: {stats['total_files']}\n")
        outfile.write(f"- Files included: {stats['included_files']}\n")
        outfile.write(f"- Files skipped (size): {stats['skipped_files']}\n")
        outfile.write(f"- Files with errors: {stats['error_files']}\n")
        outfile.write(f"- Total size of included files: {stats['total_size_mb']:.2f}MB\n")

    print(f"Source code collected in {output_file}")
    print(f"Included {stats['included_files']} files ({stats['total_size_mb']:.2f}MB)")
    print(f"Skipped {stats['skipped_files']} files (exceeded size limit)")
    print(f"Encountered errors in {stats['error_files']} files")

    return stats


def main():
    """Command-line interface for the source code collection utility."""
    parser = argparse.ArgumentParser(description='Collect source code into a single text file')
    parser.add_argument('-r', '--root', help='Root directory path (default: current directory)')
    parser.add_argument('-o', '--output', help='Output file name (default: expose.txt)')
    parser.add_argument('-e', '--exclude', nargs='+', help='Directories to exclude')
    parser.add_argument('-i', '--include', nargs='+', help='File extensions to include (e.g., .py .js)')
    parser.add_argument('-m', '--max-size', type=float, default=5.0,
                        help='Maximum file size in MB to include (default: 5MB)')
    parser.add_argument('-I', '--interactive', action='store_true',
                        help='Run in interactive mode (prompt for options)')

    args = parser.parse_args()

    # Interactive mode
    if args.interactive:
        root_input = input("Enter the root path (press Enter for current directory): ").strip()
        filename = input("Enter the output filename (default: expose.txt): ").strip()
        exclude_input = input("Enter directories to exclude (comma-separated, press Enter for defaults): ").strip()
        include_input = input("Enter file extensions to include (comma-separated, press Enter for defaults): ").strip()
        max_size_input = input("Enter maximum file size in MB (default: 5): ").strip()

        root_path = root_input if root_input else None
        output_file = filename if filename else None
        exclude_dirs = [d.strip() for d in exclude_input.split(',')] if exclude_input else None
        include_extensions = [e.strip() if e.startswith('.') else f'.{e.strip()}'
                             for e in include_input.split(',')] if include_input else None
        max_file_size = float(max_size_input) if max_size_input else 5.0
    else:
        # Command-line mode
        root_path = args.root
        output_file = args.output
        exclude_dirs = args.exclude
        include_extensions = [e if e.startswith('.') else f'.{e}' for e in args.include] if args.include else None
        max_file_size = args.max_size

    # Ensure output file has .txt extension
    if output_file and not output_file.endswith('.txt'):
        output_file += '.txt'

    # Run the collection
    collect_source_code(
        root_path=root_path,
        output_file=output_file,
        exclude_dirs=exclude_dirs,
        include_extensions=include_extensions,
        max_file_size_mb=max_file_size
    )


if __name__ == "__main__":
    main()
