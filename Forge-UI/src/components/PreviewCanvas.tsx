import React, { Suspense, useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Float, MeshDistortMaterial, Stars, PerspectiveCamera } from '@react-three/drei';
import * as THREE from 'three';
import { motion } from 'framer-motion';
import { FileCode, Folder, Zap } from 'lucide-react';

interface PreviewCanvasProps {
  selectedTemplate: string;
}

// 3D Core Element: The Forge Crystal
const ForgeCrystal: React.FC<{ color: string }> = ({ color }) => {
  const meshRef = useRef<THREE.Mesh>(null!);
  
  useFrame((state) => {
    const time = state.clock.getElapsedTime();
    meshRef.current.rotation.y = time * 0.5;
    meshRef.current.position.y = Math.sin(time) * 0.2;
  });

  return (
    <Float speed={2} rotationIntensity={0.5} floatIntensity={0.5}>
      <mesh ref={meshRef}>
        <octahedronGeometry args={[1.5, 0]} />
        <MeshDistortMaterial
          color={color}
          speed={3}
          distort={0.4}
          radius={1}
          metalness={0.8}
          roughness={0.1}
          emissive={color}
          emissiveIntensity={0.5}
        />
      </mesh>
    </Float>
  );
};

// Particles Background
const Particles: React.FC<{ color: string }> = ({ color }) => {
  const points = useMemo(() => {
    const p = new Array(500).fill(0).map(() => (Math.random() - 0.5) * 20);
    return new Float32Array(p);
  }, []);

  return (
    <points>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={points.length / 3}
          array={points}
          itemSize={3}
          args={[points, 3]}
        />
      </bufferGeometry>
      <pointsMaterial size={0.05} color={color} transparent opacity={0.6} sizeAttenuation />
    </points>
  );
};

const PreviewCanvas: React.FC<PreviewCanvasProps> = ({ selectedTemplate }) => {
  const templateColors: Record<string, string> = {
    fullstack: '#2E8B8B', // primary-bright
    mobile: '#40E0D0',    // primary-accent
    microservice: '#4A90E2', // status-info
    api: '#2E8B8B',       // status-success
    frontend: '#DAA520',  // accent-gold
    backend: '#FF7F50',   // accent-warm
  };

  const currentColor = templateColors[selectedTemplate] || '#2E8B8B';

  const projectStructure: Record<string, any> = {
    fullstack: [
      { name: 'client', type: 'folder', children: ['src', 'public', 'package.json'] },
      { name: 'server', type: 'folder', children: ['src', 'models', 'controllers'] },
      { name: 'docker-compose.yml', type: 'file' },
      { name: '.env.example', type: 'file' },
    ],
    mobile: [
      { name: 'src', type: 'folder', children: ['components', 'screens', 'navigation'] },
      { name: 'android', type: 'folder' },
      { name: 'ios', type: 'folder' },
      { name: 'package.json', type: 'file' },
    ],
    microservice: [
      { name: 'services', type: 'folder', children: ['auth', 'user', 'api-gateway'] },
      { name: 'kubernetes', type: 'folder' },
      { name: 'docker-compose.yml', type: 'file' },
    ],
  };

  const structure = projectStructure[selectedTemplate] || projectStructure.fullstack;

  return (
    <div className="h-full w-full relative flex flex-col">
      {/* 3D Scene Layer */}
      <div className="absolute inset-0 z-0 bg-background-deep/20">
        <Canvas dpr={[1, 2]}>
          <PerspectiveCamera makeDefault position={[0, 0, 5]} />
          <ambientLight intensity={0.5} />
          <pointLight position={[10, 10, 10]} intensity={1} color={currentColor} />
          <spotLight position={[-10, 10, 10]} angle={0.15} penumbra={1} intensity={1} />
          
          <Suspense fallback={null}>
            <ForgeCrystal color={currentColor} />
            <Particles color={currentColor} />
            <Stars radius={100} depth={50} count={5000} factor={4} saturation={0} fade speed={1} />
          </Suspense>

          <OrbitControls enableZoom={false} enablePan={false} autoRotate autoRotateSpeed={0.5} />
        </Canvas>
      </div>

      {/* Overlay UI: Live Structure Visualization */}
      <div className="relative z-10 flex-1 flex flex-col p-8">
        <div className="flex justify-between items-start mb-12">
          <div className="glass px-4 py-2 rounded-lg border-l-4 border-primary-bright bg-background-elevated/50 backdrop-blur-2xl border border-glass-border shadow-2xl">
            <h3 className="text-xs font-bold uppercase tracking-widest text-primary-accent">Live Generation Matrix</h3>
            <p className="text-xl font-black">Visualizing: {selectedTemplate.toUpperCase()}</p>
          </div>
          
          <div className="flex gap-4">
            <div className="glass px-4 py-2 rounded-lg flex items-center gap-2">
              <Zap size={14} className="text-primary-accent" />
              <span className="text-[10px] font-bold">Latency: 2ms</span>
            </div>
            <div className="glass px-4 py-2 rounded-lg flex items-center gap-2">
              <div className="w-1.5 h-1.5 rounded-full bg-status-success" />
              <span className="text-[10px] font-bold">Stable</span>
            </div>
          </div>
        </div>

        {/* Animated Node Graph Representation */}
        <div className="flex-1 flex items-center justify-center">
          <div className="grid grid-cols-4 gap-8 w-full max-w-4xl">
            {structure.map((item: any, idx: number) => (
              <motion.div
                key={item.name}
                initial={{ opacity: 0, y: 20, scale: 0.8 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                transition={{ delay: idx * 0.1, duration: 0.5, ease: "backOut" }}
                whileHover={{ scale: 1.1, y: -5 }}
                className="group relative flex flex-col items-center gap-3 p-6 glass border-glass-border hover:border-primary-bright transition-all duration-500 rounded-2xl cursor-default overflow-hidden"
              >
                {/* Connection Line */}
                <div className="absolute top-1/2 left-full w-8 h-[1px] bg-gradient-to-r from-primary-bright to-transparent group-last:hidden" />
                
                {/* Glow Background */}
                <div className={`absolute inset-0 opacity-0 group-hover:opacity-10 transition-opacity bg-gradient-to-br from-primary-bright to-primary-accent`} />

                {item.type === 'folder' ? (
                  <div className="p-4 rounded-2xl bg-primary-bright/10 text-primary-bright group-hover:bg-primary-bright group-hover:text-white transition-all duration-500">
                    <Folder size={32} />
                  </div>
                ) : (
                  <div className="p-4 rounded-2xl bg-primary-accent/10 text-primary-accent group-hover:bg-primary-accent group-hover:text-white transition-all duration-500">
                    <FileCode size={32} />
                  </div>
                )}
                
                <div className="text-center">
                  <span className="text-xs font-bold tracking-tight block group-hover:text-white transition-colors">{item.name}</span>
                  {item.children && (
                    <span className="text-[9px] text-text-tertiary font-medium uppercase tracking-tighter block opacity-60">
                      {item.children.length} sub-items
                    </span>
                  )}
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Project Complexity Mini-map */}
        <div className="mt-auto flex justify-end">
          <div className="glass p-4 rounded-xl w-64 bg-background-elevated/50 backdrop-blur-2xl border border-glass-border shadow-2xl">
            <div className="flex justify-between items-center mb-3">
              <span className="text-[10px] font-bold uppercase text-text-tertiary">Project Complexity</span>
              <span className="text-xs text-primary-accent font-black">78%</span>
            </div>
            <div className="h-1.5 w-full bg-background-deep rounded-full overflow-hidden border border-glass-border">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: '78%' }}
                transition={{ duration: 1.5, ease: "circOut" }}
                className="h-full bg-gradient-to-r from-primary-bright to-primary-accent" 
              />
            </div>
            <div className="grid grid-cols-2 gap-4 mt-4">
              <div className="text-[9px] text-text-tertiary">
                <span className="block font-bold text-white">48 Files</span>
                Expected output
              </div>
              <div className="text-[9px] text-text-tertiary">
                <span className="block font-bold text-white">12 Modules</span>
                Architecture
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PreviewCanvas;
