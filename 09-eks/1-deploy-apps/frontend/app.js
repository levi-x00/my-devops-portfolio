const API_URL = 'http://localhost:5000/api';

let editingId = null;

document.getElementById('itemForm').addEventListener('submit', handleSubmit);
document.getElementById('cancelBtn').addEventListener('click', cancelEdit);

async function handleSubmit(e) {
    e.preventDefault();
    
    const name = document.getElementById('itemName').value;
    const description = document.getElementById('itemDescription').value;
    
    try {
        if (editingId) {
            await fetch(`${API_URL}/items/${editingId}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, description })
            });
        } else {
            const file = document.getElementById('itemImage').files[0];
            const formData = new FormData();
            formData.append('file', file);
            const uploadRes = await fetch(`${API_URL}/upload`, { method: 'POST', body: formData });
            const { url } = await uploadRes.json();
            await fetch(`${API_URL}/items`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, description, image_url: url })
            });
        }
        
        resetForm();
        loadItems();
    } catch (error) {
        console.error('Error:', error);
    }
}

async function loadItems() {
    try {
        const response = await fetch(`${API_URL}/items`);
        const items = await response.json();
        
        const itemsList = document.getElementById('itemsList');
        itemsList.innerHTML = items.map(item => `
            <div class="item">
                <div class="item-content">
                    <h3>${item.name}</h3>
                    <p>${item.description}</p>
                    <div class="item-actions">
                        <button class="edit-btn" onclick="editItem(${item.id}, '${item.name}', '${item.description}')">Edit</button>
                        <button class="delete-btn" onclick="deleteItem(${item.id})">Delete</button>
                    </div>
                </div>
                ${item.image_url ? `<img src="${item.image_url}" alt="${item.name}">` : ''}
            </div>
        `).join('');
    } catch (error) {
        console.error('Error:', error);
    }
}

function editItem(id, name, description) {
    editingId = id;
    document.getElementById('itemName').value = name;
    document.getElementById('itemDescription').value = description;
    document.getElementById('submitBtn').textContent = 'Update Item';
    document.getElementById('cancelBtn').style.display = 'block';
}

async function deleteItem(id) {
    if (!confirm('Are you sure you want to delete this item?')) return;
    
    try {
        await fetch(`${API_URL}/items/${id}`, { method: 'DELETE' });
        loadItems();
    } catch (error) {
        console.error('Error:', error);
    }
}

function cancelEdit() {
    resetForm();
}

function resetForm() {
    editingId = null;
    document.getElementById('itemForm').reset();
    document.getElementById('submitBtn').textContent = 'Add Item';
    document.getElementById('cancelBtn').style.display = 'none';
}

loadItems();
