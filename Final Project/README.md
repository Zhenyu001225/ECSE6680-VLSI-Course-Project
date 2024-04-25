## 1.Background
The decoding process in KV Cache architectures predominantly encounters a memory-bound bottleneck, as highlighted by the profiling metrics that demonstrate memory access speeds are limiting the system's maximum performance. This constraint is evident from the significant operations per second (OPs) required by various layers, such as q-proj and k-proj, where memory access demands are high. 
![FIR Setting-w100](./fig/memory.png)

As the arithmetic intensity is low, the operations are not compute-bound, but rather restricted by the rate at which data can be fetched and stored. The roofline model visualizes this phenomenon, clearly delineating the transition from memory-bound to compute-bound regions, with the decoding steps lying within the memory-bound section. Such insights into the performance bounds are crucial for optimizing hardware and software configurations to alleviate memory-related limitations and enhance overall system efficiency.

![FIR Setting-w100](./fig/roofline.png)

One viable strategy for enhancing performance within this architecture is to minimize the volume of data transfer between the off-chip memory and the computation units. By reducing the need for frequent memory accesses, which currently act as a bottleneck due to limited memory bandwidth, we can shift the operational point closer to the compute-bound region. This approach can potentially elevate performance closer to the system's peak computational capabilities, as shown in the roofline model, and ultimately optimize the data throughput for the decoding phase of KV Cache processes.

## 2. Algorithm

![FIR Setting-w100](./fig/alg.png)


## 3. Hardware Design

![FIR Setting-w100](./fig/hd.png)
