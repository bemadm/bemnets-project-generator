import React, { useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Text, MeshDistortMaterial } from '@react-three/drei';
import * as THREE from 'three';
import { motion, AnimatePresence } from 'framer-motion';
import { X, ArrowRight, Layers, Box } from 'lucide-react';

interface TemplateExplorerProps {
  isOpen: boolean;
  onClose: () => void;
}

const TemplateCube: React.FC<{ name: string; color: string; position: [number, number, number] }> = ({ name, color, position }) => {
  const meshRef = useRef<THREE.Mesh>(null!);
  const [hovered, setHovered] = useState(false);

  useFrame((state) => {
    const time = state.clock.getElapsedTime();
    meshRef.current.rotation.x = time * 0.2;
    meshRef.current.rotation.y = time * 0.3;
    if (hovered) {
      meshRef.current.scale.setScalar(1.2 + Math.sin(time * 5) * 0.05);
    } else {
      meshRef.current.scale.setScalar(1);
    }
  });

  return (
    <group position={position}>
      <mesh 
        ref={meshRef} 
        onPointerOver={() => setHovered(true)} 
        onPointerOut={() => setHovered(false)}
      >
        <boxGeometry args={[1, 1, 1]} />
        <MeshDistortMaterial 
          color={color} 
          speed={hovered ? 5 : 2} 
          distort={hovered ? 0.4 : 0.2} 
          radius={1}
          metalness={0.8}
          roughness={0.2}
        />
      </mesh>
      <Text
        position={[0, -1.2, 0]}
        fontSize={0.2}
        color="white"
        anchorX="center"
        anchorY="middle"
        font="https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hiA.woff"
      >
        {name.toUpperCase()}
      </Text>
    </group>
  );
};

const TemplateExplorer: React.FC<TemplateExplorerProps> = ({ isOpen, onClose }) => {
  const templates = [
    { name: 'Fullstack', color: '#2E8B8B' },
    { name: 'Mobile', color: '#40E0D0' },
    { name: 'Microservice', color: '#4A90E2' },
    { name: 'API Service', color: '#2E8B8B' },
    { name: 'Frontend', color: '#DAA520' },
    { name: 'Backend', color: '#FF7F50' },
  ];

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[100] flex items-center justify-center p-12 bg-background-deep/90 backdrop-blur-3xl"
        >
          <div className="relative w-full h-full glass-elevated rounded-[3rem] overflow-hidden flex flex-col bg-background-surface/50">
            {/* Header */}
            <div className="p-8 flex justify-between items-center border-b border-glass-border">
              <div className="flex items-center gap-4">
                <div className="p-3 rounded-2xl bg-primary-bright/20 text-primary-accent">
                  <Layers size={24} />
                </div>
                <div>
                  <h2 className="text-3xl font-black tracking-tighter">TEMPLATE_GALLERY</h2>
                  <p className="text-xs text-text-tertiary uppercase tracking-[0.3em]">Explore and remix architecture blueprints</p>
                </div>
              </div>
              <motion.button
                whileHover={{ rotate: 90, scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={onClose}
                className="p-4 glass rounded-full text-text-tertiary hover:text-white transition-colors"
              >
                <X size={24} />
              </motion.button>
            </div>

            {/* 3D Explorer Content */}
            <div className="flex-1 flex gap-8 p-8 overflow-hidden">
              <div className="flex-1 glass rounded-[2rem] relative overflow-hidden">
                <Canvas camera={{ position: [0, 0, 8] }}>
                  <ambientLight intensity={0.5} />
                  <pointLight position={[10, 10, 10]} intensity={1} />
                  <spotLight position={[-10, 10, 10]} angle={0.15} penumbra={1} />
                  
                  {templates.map((tpl, i) => (
                    <TemplateCube 
                      key={tpl.name} 
                      name={tpl.name} 
                      color={tpl.color} 
                      position={[(i % 3 - 1) * 3, (1 - Math.floor(i / 3)) * 3, 0]} 
                    />
                  ))}
                  
                  <OrbitControls enableZoom={false} />
                </Canvas>
                <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 glass px-4 py-2 rounded-full text-[10px] font-black text-text-tertiary uppercase tracking-widest">
                  <Box size={12} /> Rotate Cubes to Inspect Architecture
                </div>
              </div>

              {/* Inspector Panel */}
              <div className="w-1/3 flex flex-col gap-6">
                <div className="glass p-8 rounded-[2rem] border-l-4 border-primary-bright flex-1">
                  <h3 className="text-xl font-black mb-4 tracking-tight">ARCHITECT_LOGS</h3>
                  <div className="space-y-4 font-mono text-[10px] text-text-tertiary">
                    <div className="flex justify-between border-b border-glass-border pb-2">
                      <span>Blueprint_Name:</span>
                      <span className="text-white">Fullstack_Genesis</span>
                    </div>
                    <div className="flex justify-between border-b border-glass-border pb-2">
                      <span>Complexity_Index:</span>
                      <span className="text-primary-accent">High_Performance</span>
                    </div>
                    <div className="flex justify-between border-b border-glass-border pb-2">
                      <span>Dependency_Nodes:</span>
                      <span className="text-white">12_Modules</span>
                    </div>
                    <div className="mt-6">
                      <span className="block mb-2">Structure_Summary:</span>
                      <div className="bg-background-deep/50 p-4 rounded-xl space-y-1">
                        <div className="text-primary-bright">» client/src/core</div>
                        <div className="text-primary-bright">» server/api/v1</div>
                        <div className="text-primary-bright">» docker/deployment</div>
                        <div className="text-primary-bright opacity-50">...and 45 more files</div>
                      </div>
                    </div>
                  </div>
                </div>

                <motion.button
                  whileHover={{ x: 5 }}
                  className="w-full py-6 rounded-[2rem] bg-gradient-to-r from-primary-bright to-primary-accent flex items-center justify-center gap-4 text-white font-black text-lg uppercase tracking-widest shadow-xl shadow-primary-bright/20"
                >
                  LOAD_TEMPLATE <ArrowRight size={24} />
                </motion.button>
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default TemplateExplorer;
