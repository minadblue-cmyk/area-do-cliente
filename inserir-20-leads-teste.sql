-- Script SQL para inserir 20 leads fictícios para teste
-- Todos com empresa_id = 2 para testar o isolamento

-- Limpar leads existentes da empresa 2 (opcional)
-- DELETE FROM public.lead WHERE empresa_id = 2;

-- Inserir 20 leads fictícios
INSERT INTO public.lead (
    nome, 
    telefone, 
    email, 
    profissao, 
    idade, 
    estado_civil, 
    filhos, 
    qtd_filhos, 
    status, 
    fonte_prospec, 
    contatado, 
    empresa_id, 
    usuario_id, 
    created_at, 
    updated_at, 
    data_ultima_interacao
) VALUES 
-- Lead 1
('Ana Silva Santos', '5551984123456', 'ana.silva.santos@exemplo.com', 'Engenheiro', 32, 'Casado', true, 2, 'novo', 'Indicacao', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 2
('Carlos Oliveira', '5551984234567', 'carlos.oliveira@exemplo.com', 'Medico', 45, 'Solteiro', false, 0, 'novo', 'Facebook', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 3
('Maria Fernanda', '5551984345678', 'maria.fernanda@exemplo.com', 'Advogado', 28, 'Casado', true, 1, 'novo', 'Instagram', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 4
('Joao Pedro', '5551984456789', 'joao.pedro@exemplo.com', 'Professor', 35, 'Divorciado', true, 3, 'novo', 'LinkedIn', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 5
('Lucia Mendes', '5551984567890', 'lucia.mendes@exemplo.com', 'Contador', 41, 'Casado', false, 0, 'novo', 'Google', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 6
('Roberto Alves', '5551984678901', 'roberto.alves@exemplo.com', 'Administrador', 29, 'Solteiro', true, 1, 'novo', 'Site', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 7
('Patricia Costa', '5551984789012', 'patricia.costa@exemplo.com', 'Vendedor', 33, 'Casado', true, 2, 'novo', 'Evento', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 8
('Fernando Lima', '5551984890123', 'fernando.lima@exemplo.com', 'Analista', 26, 'Solteiro', false, 0, 'novo', 'Telefone', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 9
('Camila Rodrigues', '5551984901234', 'camila.rodrigues@exemplo.com', 'Gerente', 38, 'Casado', true, 1, 'novo', 'Indicacao', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 10
('Marcos Pereira', '5551984012345', 'marcos.pereira@exemplo.com', 'Tecnico', 31, 'Divorciado', false, 0, 'novo', 'Facebook', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 11
('Juliana Souza', '5551984123456', 'juliana.souza@exemplo.com', 'Designer', 27, 'Solteiro', true, 2, 'novo', 'Instagram', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 12
('Rafael Martins', '5551984234567', 'rafael.martins@exemplo.com', 'Programador', 34, 'Casado', false, 0, 'novo', 'LinkedIn', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 13
('Beatriz Nunes', '5551984345678', 'beatriz.nunes@exemplo.com', 'Enfermeiro', 30, 'Solteiro', true, 1, 'novo', 'Google', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 14
('Diego Santos', '5551984456789', 'diego.santos@exemplo.com', 'Psicologo', 36, 'Casado', true, 3, 'novo', 'Site', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 15
('Gabriela Almeida', '5551984567890', 'gabriela.almeida@exemplo.com', 'Arquiteto', 29, 'Solteiro', false, 0, 'novo', 'Evento', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 16
('Thiago Ferreira', '5551984678901', 'thiago.ferreira@exemplo.com', 'Dentista', 42, 'Casado', true, 2, 'novo', 'Telefone', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 17
('Larissa Gomes', '5551984789012', 'larissa.gomes@exemplo.com', 'Farmaceutico', 25, 'Solteiro', true, 1, 'novo', 'Indicacao', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 18
('Andre Rocha', '5551984890123', 'andre.rocha@exemplo.com', 'Jornalista', 37, 'Divorciado', false, 0, 'novo', 'Facebook', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 19
('Vanessa Barbosa', '5551984901234', 'vanessa.barbosa@exemplo.com', 'Publicitario', 33, 'Casado', true, 2, 'novo', 'Instagram', false, 2, 6, NOW(), NOW(), NOW()),

-- Lead 20
('Felipe Cardoso', '5551984012345', 'felipe.cardoso@exemplo.com', 'Economista', 40, 'Solteiro', false, 0, 'novo', 'LinkedIn', false, 2, 6, NOW(), NOW(), NOW());

-- Verificar os leads inseridos
SELECT 
    id, 
    nome, 
    telefone, 
    email, 
    profissao, 
    idade, 
    estado_civil, 
    filhos, 
    qtd_filhos, 
    status, 
    fonte_prospec, 
    contatado, 
    empresa_id, 
    usuario_id, 
    created_at
FROM public.lead 
WHERE empresa_id = 2 
ORDER BY id DESC 
LIMIT 20;

-- Contar total de leads por empresa
SELECT 
    empresa_id, 
    COUNT(*) as total_leads,
    COUNT(CASE WHEN contatado = false THEN 1 END) as nao_contatados,
    COUNT(CASE WHEN contatado = true THEN 1 END) as contatados
FROM public.lead 
GROUP BY empresa_id 
ORDER BY empresa_id;
