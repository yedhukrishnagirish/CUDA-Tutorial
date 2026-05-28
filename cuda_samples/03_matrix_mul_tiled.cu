#include <cuda_runtime.h>
#include <iostream>
#include <vector>

constexpr int TILE = 16;

__global__ void matmul_tiled(const float* A, const float* B, float* C, int N) {
    __shared__ float As[TILE][TILE];
    __shared__ float Bs[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;
    float sum = 0.0f;

    for (int t = 0; t < (N + TILE - 1) / TILE; ++t) {
        int a_col = t * TILE + threadIdx.x;
        int b_row = t * TILE + threadIdx.y;
        As[threadIdx.y][threadIdx.x] = (row < N && a_col < N) ? A[row * N + a_col] : 0.0f;
        Bs[threadIdx.y][threadIdx.x] = (b_row < N && col < N) ? B[b_row * N + col] : 0.0f;
        __syncthreads();

        for (int k = 0; k < TILE; ++k) {
            sum += As[threadIdx.y][k] * Bs[k][threadIdx.x];
        }
        __syncthreads();
    }
    if (row < N && col < N) C[row * N + col] = sum;
}

int main() {
    int N = 512;
    size_t bytes = N * N * sizeof(float);
    std::vector<float> A(N * N, 1.0f), B(N * N, 2.0f), C(N * N);
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes); cudaMalloc(&d_B, bytes); cudaMalloc(&d_C, bytes);
    cudaMemcpy(d_A, A.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B.data(), bytes, cudaMemcpyHostToDevice);
    dim3 threads(TILE, TILE);
    dim3 blocks((N + TILE - 1) / TILE, (N + TILE - 1) / TILE);
    matmul_tiled<<<blocks, threads>>>(d_A, d_B, d_C, N);
    cudaMemcpy(C.data(), d_C, bytes, cudaMemcpyDeviceToHost);
    std::cout << "C[0] = " << C[0] << "\n";
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    return 0;
}
