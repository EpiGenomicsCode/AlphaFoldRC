import pandas as pd
import numpy as np
import os
import sys

def parse_percentage(value):
    return float(value.strip(' %'))

def generate_summary(log_dir, job_name):
    try:
        cpu_usage_file = os.path.join(log_dir, f'{job_name}_gpu_cpu_usage.log')
        cpu_usage = pd.read_csv(cpu_usage_file, sep='\s+', header=None, skiprows=1)
        
        us_column_index = cpu_usage.iloc[0].tolist().index('us')
        
        cpu_usage[us_column_index] = pd.to_numeric(cpu_usage[us_column_index].iloc[1:], errors='coerce')

        gpu_usage_file = os.path.join(log_dir, f'{job_name}_gpu_usage.log')
        gpu_usage = pd.read_csv(gpu_usage_file, header=0, parse_dates=[0])
        gpu_usage[' utilization.gpu [%]'] = gpu_usage[' utilization.gpu [%]'].apply(parse_percentage)
        gpu_usage[' utilization.memory [%]'] = gpu_usage[' utilization.memory [%]'].apply(parse_percentage)

        summary_file = os.path.join(log_dir, f'{job_name}_utilization_summary.txt')
        with open(summary_file, 'w') as f:
            f.write('CPU Utilization Summary:\n')
            f.write(f'Average CPU usage: {cpu_usage[us_column_index].mean():.2f}%\n')
            f.write(f'Max CPU usage: {cpu_usage[us_column_index].max():.2f}%\n\n')
            
            f.write('GPU Utilization Summary:\n')
            f.write(f'Average GPU usage: {gpu_usage[" utilization.gpu [%]"].mean():.2f}%\n')
            f.write(f'Max GPU usage: {gpu_usage[" utilization.gpu [%]"].max():.2f}%\n')
            f.write(f'Average GPU memory usage: {gpu_usage[" utilization.memory [%]"].mean():.2f}%\n')
            f.write(f'Max GPU memory usage: {gpu_usage[" utilization.memory [%]"].max():.2f}%\n')

        print(f"Summary written to {summary_file}")

    except Exception as e:
        print(f"Error generating summary: {str(e)}")
        
        summary_file = os.path.join(log_dir, f'{job_name}_utilization_summary.txt')
        with open(summary_file, 'w') as f:
            f.write(f'Error generating summary: {str(e)}\n')

        print("\nDebug Information:")
        print(f"CPU usage file exists: {os.path.exists(cpu_usage_file)}")
        print(f"GPU usage file exists: {os.path.exists(gpu_usage_file)}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_summary.py <log_dir> <job_name>")
        sys.exit(1)
    
    log_dir = sys.argv[1]
    job_name = sys.argv[2]
    generate_summary(log_dir, job_name)