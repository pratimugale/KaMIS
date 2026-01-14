# MMWIS Example Usage

This document shows how to run the `mmwis` (Memetic Maximum Weight Independent Set) algorithm on example graphs and handle the output.

## Basic Usage

### Running on an Example Graph

The KaMIS repository includes example graphs in the `examples/` directory. Here's how to run mmwis:

```bash
# Navigate to the mmwis deploy directory (after compilation)
cd KaMIS/mmwis/deploy

# Run mmwis on a simple example graph
./mmwis ../../examples/simple.graph --output=simple_solution.txt

# Run on a weighted graph
./mmwis ../../examples/weight_nodes.graph --output=weighted_solution.txt
```

### Command-Line Options

The most important options for basic usage:

- `FILE` - Path to the graph file (required)
- `--output=<string>` - Path to store the resulting independent set
- `--seed=<int>` - Seed for random number generator
- `--time_limit=<double>` - Time limit in seconds (default: 1000s)
- `--config=<string>` - Configuration: `mmwis` (default) or `mmwiss`
- `--console_log` - Write log to console instead of file
- `--help` - Show all available options

### Example with Options

```bash
./mmwis ../../examples/weight_nodes.graph \
    --output=result.txt \
    --seed=42 \
    --time_limit=60.0 \
    --config=mmwis \
    --console_log
```

## Output Format

The output file (specified with `--output`) contains one line per node in the graph. Each line is either:
- `0` - Node is NOT in the independent set
- `1` - Node IS in the independent set

The nodes are written in order (node 0, node 1, node 2, ...).

### Example Output File

For a graph with 6 nodes, the output might look like:
```
0
1
0
1
0
0
```

This means nodes 1 and 3 (0-indexed) are in the independent set.

## Reading the Results

### Python Example

```python
def read_independent_set(filename):
    """Read mmwis output file and return list of node IDs in the independent set."""
    independent_set_nodes = []
    with open(filename, 'r') as f:
        for node_id, line in enumerate(f):
            if line.strip() == '1':
                independent_set_nodes.append(node_id)
    return independent_set_nodes

# Usage
nodes = read_independent_set('simple_solution.txt')
print(f"Independent set contains {len(nodes)} nodes: {nodes}")
```

### Julia Example

```julia
function read_independent_set(filename::String)
    """Read mmwis output file and return vector of node IDs in the independent set."""
    independent_set_nodes = Int[]
    open(filename, "r") do f
        for (node_id, line) in enumerate(eachline(f))
            if strip(line) == "1"
                push!(independent_set_nodes, node_id)
            end
        end
    end
    return independent_set_nodes
end

# Usage
nodes = read_independent_set("simple_solution.txt")
println("Independent set contains $(length(nodes)) nodes: $nodes")
```

## Graph File Format

MMWIS expects graphs in METIS format. The format is:

**Header line:**
```
n_nodes n_edges [format_code]
```

Where `format_code` is:
- `0` or omitted: no weights
- `1`: edge weights only
- `10`: node weights only
- `11`: both edge and node weights

**Node lines:**
For each node, one line with:
- Node weight (if format_code includes node weights)
- Neighbor list (space-separated, 1-indexed)

### Example Graph File

```
6 7 10
2 2 6
1 1 3 6
2 2 4
1 3 5
2 4 6
1 1 2 5
```

This represents:
- 6 nodes, 7 edges, with node weights (format code 10)
- Node 0: weight=2, neighbors: nodes 1, 5 (0-indexed: 2, 6 in file)
- Node 1: weight=1, neighbors: nodes 0, 2, 5
- etc.

## Complete Example Workflow

```bash
# 1. Compile mmwis (if not already done)
cd KaMIS/mmwis
./compile.sh Release

# 2. Run on example graph
cd deploy
./mmwis ../../examples/simple.graph --output=simple_result.txt --console_log

# 3. Check the output
cat simple_result.txt

# 4. Parse results (Python)
python3 << EOF
with open('simple_result.txt') as f:
    nodes = [i for i, line in enumerate(f) if line.strip() == '1']
    print(f"Independent set: {nodes}")
EOF
```

## Additional Options

### Writing the Kernel

You can also save the reduced graph (kernel) after reductions:

```bash
./mmwis graph.graph --output=solution.txt --kernel=kernel.graph
```

### Different Configurations

- `--config=mmwis` - Standard memetic algorithm
- `--config=mmwiss` - Uses struction algorithm in initial population

### Weight Sources

- `--weight_source=file` - Read weights from file (default)
- `--weight_source=uniform` - Uniform weights
- `--weight_source=geometric` - Geometric distribution
- `--weight_source=unit` - All weights = 1

## Notes

- The algorithm uses the graph's `PartitionIndex` to mark nodes in the independent set
- Node indices in the output file are 0-indexed (first node = 0)
- The output format is simple text, one value per line
- If `--output` is not specified, results are not written to a file (but may be printed to console/log)





