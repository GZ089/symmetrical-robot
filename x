<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>B2B Admin | Firestore</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
</head>
<body class="bg-gray-100">
  <!-- Login Page -->
  <div id="loginPage" class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-600 to-indigo-800">
    <div class="bg-white p-8 rounded-xl shadow-2xl w-96">
      <h2 class="text-3xl font-bold text-center mb-6">Admin Panel</h2>
      <div class="space-y-3 mb-4">
        <input id="email" type="email" placeholder="Admin Email" class="w-full border p-3 rounded" value="admin@b2b.com">
        <input id="password" type="password" placeholder="Password" class="w-full border p-3 rounded" value="123456">
        <button onclick="login()" class="w-full bg-blue-600 text-white py-3 rounded font-semibold hover:bg-blue-700">Sign In</button>
      </div>
      <div class="relative my-4"><div class="absolute inset-0 flex items-center"><div class="w-full border-t"></div></div><div class="relative flex justify-center text-sm"><span class="px-2 bg-white text-gray-500">Or continue with</span></div></div>
      <button onclick="googleLogin()" class="w-full bg-white border border-gray-300 text-gray-700 py-3 rounded font-semibold hover:bg-gray-50 flex items-center justify-center gap-2">
        <i class="fab fa-google text-red-500"></i> Sign in with Google
      </button>
      <p id="loginError" class="text-red-500 text-sm text-center mt-3"></p>
    </div>
  </div>

  <!-- Dashboard -->
  <div id="dashboard" class="hidden flex h-screen">
    <aside class="w-64 bg-gray-900 text-white p-4 flex flex-col">
      <h1 class="text-2xl font-bold text-blue-300 mb-6">B2B Admin</h1>
      <nav class="flex flex-col gap-1 flex-1">
        <a href="#" onclick="switchCol('b2borders')" class="nav-link flex items-center gap-3 p-3 rounded bg-blue-700"><i class="fas fa-shopping-cart"></i>Orders</a>
        <a href="#" onclick="switchCol('supplierApplications')" class="nav-link flex items-center gap-3 p-3 rounded hover:bg-blue-700"><i class="fas fa-user-tie"></i>Sellers</a>
        <a href="#" onclick="switchCol('merchantApplications')" class="nav-link flex items-center gap-3 p-3 rounded hover:bg-blue-700"><i class="fas fa-store"></i>Merchants</a>
        <a href="#" onclick="switchCol('connectedShops')" class="nav-link flex items-center gap-3 p-3 rounded hover:bg-blue-700"><i class="fas fa-link"></i>Shops</a>
        <a href="#" onclick="switchCol('B2BWebsiteData')" class="nav-link flex items-center gap-3 p-3 rounded hover:bg-blue-700"><i class="fas fa-globe"></i>Websites</a>
        <a href="#" onclick="switchCol('inheritedData')" class="nav-link flex items-center gap-3 p-3 rounded hover:bg-blue-700"><i class="fas fa-database"></i>Inherited</a>
      </nav>
      <div class="mt-auto space-y-2">
        <div class="text-sm text-gray-400 px-3" id="userEmail"></div>
        <button onclick="logout()" class="w-full bg-red-600 hover:bg-red-700 p-3 rounded text-center">Logout</button>
      </div>
    </aside>

    <main class="flex-1 overflow-y-auto p-6">
      <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
        <div class="bg-white p-4 rounded shadow"><p class="text-sm text-gray-500">Orders</p><p id="tOrders" class="text-2xl font-bold">0</p></div>
        <div class="bg-white p-4 rounded shadow"><p class="text-sm text-gray-500">Sellers</p><p id="tSellers" class="text-2xl font-bold">0</p></div>
        <div class="bg-white p-4 rounded shadow"><p class="text-sm text-gray-500">Merchants</p><p id="tMerchants" class="text-2xl font-bold">0</p></div>
        <div class="bg-white p-4 rounded shadow"><p class="text-sm text-gray-500">Pending</p><p id="tPending" class="text-2xl font-bold text-yellow-600">0</p></div>
        <div class="bg-white p-4 rounded shadow"><p class="text-sm text-gray-500">Approved</p><p id="tApproved" class="text-2xl font-bold text-green-600">0</p></div>
      </div>

      <div class="bg-white p-4 rounded shadow mb-4 flex flex-wrap gap-3 items-center">
        <h2 id="colTitle" class="text-xl font-semibold mr-auto">Orders</h2>
        <input id="search" placeholder="Search..." class="border px-3 py-2 rounded text-sm w-40" oninput="filter()">
        <select id="statusFilter" class="border px-3 py-2 rounded text-sm" onchange="filter()"></select>
        <input id="dateFrom" type="date" class="border px-3 py-2 rounded text-sm" onchange="filter()">
        <input id="dateTo" type="date" class="border px-3 py-2 rounded text-sm" onchange="filter()">
        <button onclick="filter()" class="bg-blue-600 text-white px-4 py-2 rounded text-sm">Filter</button>
        <button onclick="clearFilters()" class="bg-gray-300 px-4 py-2 rounded text-sm">Clear</button>
        <div class="relative inline-block">
          <button id="exportBtn" onclick="toggleExportMenu()" class="bg-green-600 text-white px-4 py-2 rounded text-sm"><i class="fas fa-download"></i> Export</button>
          <div id="exportMenu" class="hidden absolute right-0 mt-2 w-48 bg-white rounded shadow-lg z-10 border">
            <button onclick="exportData('csv')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-file-csv text-green-600 mr-2"></i>CSV</button>
            <button onclick="exportData('excel')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-file-excel text-green-700 mr-2"></i>Excel</button>
            <button onclick="exportData('pdf')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-file-pdf text-red-600 mr-2"></i>PDF</button>
            <button onclick="exportData('word')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-file-word text-blue-600 mr-2"></i>Word</button>
            <button onclick="exportData('html')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-code text-orange-600 mr-2"></i>HTML</button>
            <button onclick="exportData('json')" class="block w-full text-left px-4 py-2 hover:bg-gray-100 text-sm"><i class="fas fa-brackets-curly text-purple-600 mr-2"></i>JSON</button>
          </div>
        </div>
      </div>

      <div id="tableContainer" class="bg-white rounded shadow overflow-x-auto">
        <table class="w-full text-left">
          <thead class="bg-gray-50"><tr><th class="p-3">Name</th><th class="p-3">Phone</th><th class="p-3">Roll No</th><th class="p-3">Status</th><th class="p-3">Date</th><th class="p-3">Actions</th></tr></thead>
          <tbody id="tableBody"></tbody>
        </table>
      </div>

      <div class="flex justify-between mt-4">
        <button onclick="prevPage()" id="prevBtn" class="px-4 py-2 bg-white border rounded disabled:opacity-50">Previous</button>
        <span id="pageInfo" class="text-sm">Page 1</span>
        <button onclick="nextPage()" id="nextBtn" class="px-4 py-2 bg-white border rounded disabled:opacity-50">Next</button>
      </div>
    </main>
  </div>

  <!-- Edit Modal -->
  <div id="modal" class="hidden fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50" onclick="if(event.target===this)closeModal()">
    <div class="bg-white rounded-xl shadow-xl w-full max-w-2xl mx-4 max-h-[80vh] overflow-y-auto p-6 relative">
      <button onclick="closeModal()" class="absolute top-3 right-3 text-gray-500 text-xl">&times;</button>
      <div id="modalBody"></div>
    </div>
  </div>

  <script>
    firebase.initializeApp({
      apiKey: "AIzaSyB44kAWSIrjWmYH75g16-J_Mnkip-HvNBM",
      authDomain: "ayshamall.firebaseapp.com",
      projectId: "ayshamall",
      storageBucket: "ayshamall.firebasestorage.app",
      messagingSenderId: "319564197871",
      appId: "1:319564197871:web:d0de1f012835234494d01a"
    });
    const auth = firebase.auth();
    const db = firebase.firestore();
    const googleProvider = new firebase.auth.GoogleAuthProvider();

    const COLS = {
      orders:'b2borders', supplier:'supplierApplications', merchant:'merchantApplications',
      shops:'connectedShops', website:'B2BWebsiteData', inherited:'inheritedData'
    };
    let curCol = 'b2borders', page = 1, lastDoc = null, filters = {search:'',status:'',from:'',to:''};

    auth.onAuthStateChanged(u => {
      if(u) { 
        document.getElementById('loginPage').classList.add('hidden'); 
        document.getElementById('dashboard').classList.remove('hidden');
        document.getElementById('userEmail').textContent = u.email;
        loadStats(); 
        switchCol('b2borders'); 
      } else { 
        document.getElementById('loginPage').classList.remove('hidden'); 
        document.getElementById('dashboard').classList.add('hidden'); 
      }
    });

    window.login = () => auth.signInWithEmailAndPassword(email.value, password.value).catch(e => loginError.textContent = e.message);
    window.googleLogin = () => auth.signInWithPopup(googleProvider).catch(e => loginError.textContent = e.message);
    window.logout = () => auth.signOut();

    function switchCol(col) {
      curCol = col; 
      document.querySelectorAll('.nav-link').forEach(l=>l.classList.remove('bg-blue-700'));
      event.target.closest('.nav-link')?.classList.add('bg-blue-700');
      document.getElementById('colTitle').textContent = col.replace(/([A-Z])/g,' $1').trim();
      const sf = document.getElementById('statusFilter');
      if(col.includes('Application')) sf.innerHTML = `<option value="">All</option><option>pending</option><option>approved</option><option>rejected</option>`;
      else if(col==='b2borders') sf.innerHTML = `<option value="">All</option><option>completed</option><option>pending</option><option>processing</option>`;
      else sf.innerHTML = `<option value="">All</option><option>active</option><option>inactive</option>`;
      clearFilters();
    }

    function clearFilters() {
      search.value=statusFilter.value=dateFrom.value=dateTo.value='';
      filters={search:'',status:'',from:'',to:''}; page=1; lastDoc=null; fetchDocs();
    }

    function filter() {
      filters.search=search.value.toLowerCase(); filters.status=statusFilter.value;
      filters.from=dateFrom.value; filters.to=dateTo.value; page=1; lastDoc=null; fetchDocs();
    }

    async function loadStats() {
      try {
        const [o,s,m,sp,sa,mp,ma] = await Promise.all([
          db.collection(COLS.orders).get(), db.collection(COLS.supplier).get(), db.collection(COLS.merchant).get(),
          db.collection(COLS.supplier).where('status','==','pending').get(),
          db.collection(COLS.supplier).where('status','==','approved').get(),
          db.collection(COLS.merchant).where('status','==','pending').get(),
          db.collection(COLS.merchant).where('status','==','approved').get()
        ]);
        tOrders.textContent=o.size; tSellers.textContent=s.size; tMerchants.textContent=m.size;
        tPending.textContent=sp.size+mp.size; tApproved.textContent=sa.size+ma.size;
      } catch(e) {}
    }

    async function fetchDocs() {
      tableBody.innerHTML='<tr><td colspan="6" class="p-4 text-center">Loading...</td></tr>';
      try {
        let q = db.collection(curCol);
        if(filters.status) q = q.where('status','==',filters.status);
        if(filters.from) q = q.where('createdAt','>=',new Date(filters.from));
        if(filters.to) q = q.where('createdAt','<=',new Date(filters.to+'T23:59:59'));
        q = q.orderBy('createdAt','desc');
        if(page>1 && lastDoc) q = q.startAfter(lastDoc);
        q = q.limit(10);
        const snap = await q.get();
        let docs = snap.docs.map(d=>({id:d.id,...d.data()}));
        if(filters.search) docs = docs.filter(d=>JSON.stringify(d).toLowerCase().includes(filters.search));
        
        tableBody.innerHTML = docs.length ? docs.map(d=>{
          const st = d.status||'—', nm = d.websiteName||d.shopName||d.fullName||d.storeName||d.rollNumber||'—';
          const ph = d.phone||d.businessNumber||d.ownerNumber||d.number||'';
          const rn = d.rollNumber||d.sellerRollNumber||'—';
          const dt = d.createdAt ? new Date(d.createdAt.seconds?d.createdAt.seconds*1000:d.createdAt).toLocaleDateString() : '';
          const sc = st==='approved'||st==='completed'||st==='active'?'bg-green-100 text-green-800':st==='pending'?'bg-yellow-100 text-yellow-800':st==='rejected'?'bg-red-100 text-red-800':'bg-gray-100';
          return `<tr class="border-b hover:bg-gray-50">
            <td class="p-3 text-sm">${nm}</td><td class="p-3 text-sm">${ph||'—'}</td><td class="p-3 text-sm">${rn}</td>
            <td class="p-3"><span class="px-2 py-1 rounded text-xs ${sc}">${st}</span></td><td class="p-3 text-sm">${dt}</td>
            <td class="p-3 flex gap-2">
              <button onclick='edit("${d.id}",${JSON.stringify(d).replace(/'/g,"&#39;")})' class="text-blue-600"><i class="fas fa-edit"></i></button>
              <button onclick="del('${d.id}')" class="text-red-500"><i class="fas fa-trash"></i></button>
              ${ph?`<a href="https://wa.me/${ph.replace(/\D/g,'')}" target="_blank" class="text-green-600"><i class="fab fa-whatsapp"></i></a><a href="sms:${ph.replace(/\D/g,'')}" class="text-gray-600"><i class="fas fa-sms"></i></a>`:''}
              ${st==='pending'&&curCol.includes('Application')?`<button onclick="approve('${d.id}','approved')" class="text-green-700 text-xs bg-green-100 px-2 rounded">Approve</button><button onclick="approve('${d.id}','rejected')" class="text-red-700 text-xs bg-red-100 px-2 rounded">Reject</button>`:''}
            </td></tr>`;
        }).join('') : '<tr><td colspan="6" class="p-6 text-center text-gray-400">No records</td></tr>';
        
        lastDoc = snap.docs[snap.docs.length-1] || null;
        document.getElementById('pageInfo').textContent = `Page ${page}`;
        prevBtn.disabled = page<=1;
        nextBtn.disabled = snap.docs.length<10;
      } catch(e) { tableBody.innerHTML=`<tr><td colspan="6" class="p-4 text-red-500">Error: ${e.message}</td></tr>`; }
    }

    window.edit = (id,data) => {
      modalBody.innerHTML = `<h3 class="text-lg font-bold mb-4">Edit: ${id}</h3>`+
        Object.entries(data).filter(([k])=>!['id','createdAt','updatedAt'].includes(k)).map(([k,v])=>{
          const t = typeof v==='boolean'?'checkbox':'text';
          return `<div class="mb-3"><label class="block text-sm mb-1">${k}</label><input type="${t}" id="e_${k}" value="${typeof v==='object'?JSON.stringify(v):v||''}" class="w-full border rounded px-3 py-2 text-sm" ${t==='checkbox'&&v?'checked':''}></div>`;
        }).join('')+
        `<div class="flex justify-end gap-3 mt-4"><button onclick="closeModal()" class="px-4 py-2 bg-gray-300 rounded">Cancel</button>
        <button onclick="save('${id}')" class="px-4 py-2 bg-blue-600 text-white rounded">Save</button></div>`;
      modal.classList.remove('hidden');
    };

    window.save = async (id) => {
      const data = {}; modalBody.querySelectorAll('input').forEach(i=>{
        data[i.id.slice(2)] = i.type==='checkbox'?i.checked:(isNaN(i.value)||i.value===''?i.value:Number(i.value));
      });
      data.updatedAt = new Date();
      await db.collection(curCol).doc(id).update(data);
      closeModal(); fetchDocs(); loadStats();
    };

    window.approve = async (id,st) => {
      if(confirm(`Set to ${st}?`)) { await db.collection(curCol).doc(id).update({status:st,updatedAt:new Date()}); fetchDocs(); loadStats(); }
    };

    window.del = async (id) => {
      if(confirm('Delete permanently?')) { await db.collection(curCol).doc(id).delete(); fetchDocs(); loadStats(); }
    };

    window.closeModal = () => modal.classList.add('hidden');
    window.prevPage = () => { if(page>1){page--; lastDoc=null; fetchDocs();} };
    window.nextPage = () => { page++; fetchDocs(); };

    window.toggleExportMenu = () => document.getElementById('exportMenu').classList.toggle('hidden');
    
    document.addEventListener('click', (e) => {
      if (!e.target.closest('#exportBtn') && !e.target.closest('#exportMenu')) {
        document.getElementById('exportMenu').classList.add('hidden');
      }
    });

    async function getAllDocs() {
      let q = db.collection(curCol).orderBy('createdAt','desc');
      if(filters.status) q = q.where('status','==',filters.status);
      const snap = await q.get();
      let docs = snap.docs.map(d=>({id:d.id,...d.data()}));
      if(filters.search) docs = docs.filter(d=>JSON.stringify(d).toLowerCase().includes(filters.search));
      return docs;
    }

    function getTableHTML(docs) {
      const headers = Object.keys(docs[0] || {}).filter(k=>!['profileImage','logoBase64'].includes(k));
      return `<!DOCTYPE html><html><head><meta charset="UTF-8"><title>${curCol}</title>
        <style>body{font-family:Arial,sans-serif;margin:20px}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px;text-align:left}th{background:#f3f4f6}.status-green{color:green}.status-yellow{color:#b45309}.status-red{color:red}</style></head><body>
        <h2>${curCol} Export</h2><p>Generated: ${new Date().toLocaleString()}</p>
        <table><tr>${headers.map(h=>`<th>${h}</th>`).join('')}</tr>
        ${docs.map(d=>`<tr>${headers.map(h=>`<td>${d[h]||''}</td>`).join('')}</tr>`).join('')}</table></body></html>`;
    }

    window.exportData = async (format) => {
      document.getElementById('exportMenu').classList.add('hidden');
      const docs = await getAllDocs();
      if(!docs.length) return alert('No data to export');
      const headers = Object.keys(docs[0]).filter(k=>!['profileImage','logoBase64'].includes(k));

      switch(format) {
        case 'csv':
          const csv = headers.join(',')+'\n'+docs.map(d=>headers.map(h=>`"${String(d[h]||'').replace(/"/g,'""')}"`).join(',')).join('\n');
          download(csv, `${curCol}.csv`, 'text/csv');
          break;
        case 'excel':
          const excelHTML = `<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">
            <head><meta charset="UTF-8"><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>
            <x:Name>${curCol}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet>
            </x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>
            <tr>${headers.map(h=>`<th>${h}</th>`).join('')}</tr>
            ${docs.map(d=>`<tr>${headers.map(h=>`<td>${d[h]||''}</td>`).join('')}</tr>`).join('')}</table></body></html>`;
          download(new Blob([excelHTML],{type:'application/vnd.ms-excel'}), `${curCol}.xls`);
          break;
        case 'pdf':
          const pdfContent = document.createElement('div');
          pdfContent.innerHTML = getTableHTML(docs);
          pdfContent.style.padding = '20px';
          document.body.appendChild(pdfContent);
          await html2pdf().set({margin:10,filename:`${curCol}.pdf`,image:{type:'jpeg',quality:0.98},html2canvas:{scale:2},jsPDF:{unit:'mm',format:'a4',orientation:'landscape'}}).from(pdfContent).save();
          document.body.removeChild(pdfContent);
          break;
        case 'word':
          const wordHTML = getTableHTML(docs);
          download(new Blob(['\ufeff'+wordHTML],{type:'application/msword'}), `${curCol}.doc`);
          break;
        case 'html':
          download(getTableHTML(docs), `${curCol}.html`, 'text/html');
          break;
        case 'json':
          download(JSON.stringify(docs,null,2), `${curCol}.json`, 'application/json');
          break;
      }
    };

    function download(content, name, type) {
      const a = document.createElement('a');
      a.href = URL.createObjectURL(content instanceof Blob ? content : new Blob([content],{type}));
      a.download = name; a.click();
    }
  </script>
</body>
</html>