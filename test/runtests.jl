using AxisArrays
using Base.Test

A = AxisArray(reshape(1:24, 2,3,4), (.1:.1:.2, .1:.1:.3, .1:.1:.4))
# Test enumeration
for (a,b) in zip(A, A.data)
    @test a == b
end
for idx in eachindex(A)
    @test A[idx] == A.data[idx]
end

# Test slices
@test A == A.data
@test A[:,:,:] == A[Axis{:row}(:)] == A[Axis{:col}(:)] == A[Axis{:page}(:)] == A.data[:,:,:]
# Test UnitRange slices
@test A[1:2,:,:] == A.data[1:2,:,:] == A[Axis{:row}(1:2)]
@test A[:,1:2,:] == A.data[:,1:2,:] == A[Axis{:col}(1:2)]
@test A[:,:,1:2] == A.data[:,:,1:2] == A[Axis{:page}(1:2)]
# Test scalar slices
@test A[2,:,:] == A.data[2,:,:] == A[Axis{:row}(2)]
@test A[:,2,:] == A.data[:,2,:] == A[Axis{:col}(2)]
@test A[:,:,2] == A.data[:,:,2] == A[Axis{:page}(2)]

# Test fallback methods
@test A[[1 2; 3 4]] == A.data[[1 2; 3 4]]

# Test axis restrictions
@test A[:,:,:].axes == A.axes

@test A[Axis{:row}(1:2)].axes[1] == A.axes[1][1:2]
@test A[Axis{:row}(1:2)].axes[2:3] == A.axes[2:3]

@test A[Axis{:col}(1:2)].axes[2] == A.axes[2][1:2]
@test A[Axis{:col}(1:2)].axes[[1,3]] == A.axes[[1,3]]

@test A[Axis{:page}(1:2)].axes[3] == A.axes[3][1:2]
@test A[Axis{:page}(1:2)].axes[1:2] == A.axes[1:2]

# Linear indexing across multiple dimensions drops tracking of those dims
@test A[:].axes == ()
@test A[1:2,:].axes == (A.axes[1][1:2],)

B = AxisArray(reshape(1:15, 5,3), (.1:.1:0.5, [:a, :b, :c]))

# Test indexing by Intervals
@test B[Interval(0.0,  0.5), :] == B[:,:]
@test B[Interval(0.0,  0.3), :] == B[1:3,:]
@test B[Interval(0.15, 0.3), :] == B[2:3,:]
@test B[Interval(0.2,  0.5), :] == B[2:end,:]
@test B[Interval(0.2,  0.6), :] == B[2:end,:]

# Test Categorical indexing
@test B[:, :a] == B[:,1]
@test B[:, :c] == B[:,3]
@test B[:, [:a]] == B[:,[1]]
@test B[:, [:a,:c]] == B[:,[1,3]]

@test B[Axis{:row}(Interval(0.15, 0.3))] == B[2:3,:]

A = AxisArray(reshape(1:256, 4,4,4,4), (.1:.1:.4, 1//10:1//10:4//10, ["1","2","3","4"], [:a, :b, :c, :d]), (:d1,:d2,:d3,:d4))
@test A.data[1:2,:,:,:] == A[Axis{:d1}(Interval(.1,.2))]       == A[Interval(.1,.2),:,:,:]       == A[Interval(.1,.2),:,:,:,1]
@test A.data[:,1:2,:,:] == A[Axis{:d2}(Interval(1//10,2//10))] == A[:,Interval(1//10,2//10),:,:] == A[:,Interval(1//10,2//10),:,:,1]
@test A.data[:,:,1:2,:] == A[Axis{:d3}(["1","2"])]             == A[:,:,["1","2"],:]             == A[:,:,["1","2"],:,1]
@test A.data[:,:,:,1:2] == A[Axis{:d4}([:a,:b])]               == A[:,:,:,[:a,:b]]               == A[:,:,:,[:a,:b],1]
