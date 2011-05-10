/*
 *  untitled.h
 *  VectorRacer
 *
 *  Created by Jonathan Nobels on 10-02-26.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */
#import "OpenGLCommon.h"
#import "Vector.h"
#import "Matrix.h"
#import "Quaternion.h"
#import "Transform.h"

#import "matrix_impl.h"

#include <cmath>


template <class T>
class vec3 {
public:
	T x, y, z;
	
	vec3(){x=0; y=0; z=0;}
	
	vec3(T X, T Y, T Z){
		x=X;
		y=Y;
		z=Z;
	}
	
	vec3(Vector3D v){
		x = (T)v.x;
		y = (T)v.y;
		z = (T)v.z;
	}
	
	vec3(Vec3 v){
		x = v.x;
		y = v.y;
		z = v.z;
	}
	
	vec3 operator+ (vec3  b){
		return vec3(x+b.x, y+b.y, z+b.z);
	}
	
	vec3 operator- (vec3  b){
		return vec3(x-b.x, y-b.y, z-b.z);
	}
	
	vec3 operator* (T b){
		return vec3(x*b, y*b, z*b);
	}
	
	T operator* (vec3 b){
		return x*b.x + y*b.y + z*b.z;
	}
	
	vec3 operator/ (T b){
		return vec3(x/b, y/b, z/b);
	}
	
	vec3 cross    ( vec3  b){
		return vec3(y*b.z-z*b.y, z*b.x-x*b.z, x*b.y-y*b.x);
	}
	
	T dot( vec3 b){
		return x*b.x+y*b.y+z*b.z;
	}
	
	vec3 normalize()
	{
		T c = 1.0f/ length();
		return vec3(x*c, y*c, z*c);
	}
	
	Vector3D v(){
		return Vector3DMake(x,y,z);
	}
	
	Vec3 makeVec3(){
		return Vec3((T)x,(T)y,(T)z);
	}
	
	T length(){
		return sqrtf(x*x + y*y + z*z);
	}
	
	T length2(){
		return x*x + y*y + z*z;
	}
	
	T* array(){
		T arr[3] = {x, y, z}; 
		return arr;
	}
	
};



template <class T>
class vec2 {
public:
	T x, y;
	
	vec2(){x=0; y=0;}
	
	vec2(T X, T Y){
		x=X;
		y=Y;
	}
	
	vec2 operator+ (vec2  b){
		return vec2(x+b.x, y+b.y);
	}
	
	vec2 operator- (vec2  b){
		return vec2(x-b.x, y-b.y);
	}
	
	vec2 operator* (T b){
		return vec2(x*b, y*b);
	}
	
	T operator* (vec2  b){
		return x*b.x + y*b.y;
	}
	
	vec2 operator/ (T b){
		return vec2(x/b, y/b);
	}
	
	vec2 normalize()
	{
		T c = 1/ length();
		return vec2(x*c, y*c);
	}
	
	Vector3D v()
	{
		return Vector3DMake(x,y,-2);
	}
	
	T length(){
		return sqrtf(x*x + y*y);
	}

	T length2(){
		return x*x + y*y;
	}

	T* array(){
		T arr[2] = {x, y};
		return arr;
	}
	
};


typedef vec2<float> vec2f;

typedef vec3<int> vec3i;
typedef vec2<int> vec2i;

typedef vec3<double> vec3d;
typedef vec2<double> vec2d;
