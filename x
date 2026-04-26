<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Seller Applications</title>

  <!-- Firebase v8 CDN (non-modular) -->
  <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js"></script>

  <!-- PDF Library -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

  <style>
    body {
      font-family: Arial;
      background: #f4f6f8;
      padding: 20px;
    }

    .card {
      background: white;
      padding: 20px;
      border-radius: 10px;
      margin-bottom: 20px;
      box-shadow: 0 0 8px rgba(0,0,0,0.1);
    }

    .logo img {
      max-width: 120px;
      margin-bottom: 10px;
    }

    button {
      margin-top: 10px;
      padding: 8px 15px;
      border: none;
      background: #007bff;
      color: white;
      border-radius: 5px;
      cursor: pointer;
    }
  </style>
</head>

<body>

<h2>Seller Applications</h2>
<div id="dataContainer">Loading...</div>

<script>
  // ✅ Firebase Config
  var firebaseConfig = {
    apiKey: "AIzaSyB44kAWSIrjWmYH75g16-J_Mnkip-HvNBM",
    authDomain: "ayshamall.firebaseapp.com",
    projectId: "ayshamall",
    storageBucket: "ayshamall.firebasestorage.app",
    messagingSenderId: "319564197871",
    appId: "1:319564197871:web:d0de1f012835234494d01a"
  };

  // ✅ Initialize Firebase
  firebase.initializeApp(firebaseConfig);
  var db = firebase.firestore();

  var container = document.getElementById("dataContainer");

  function loadData() {
    container.innerHTML = "Loading...";

    db.collection("sellerApplications").get()
      .then(function(querySnapshot) {
        container.innerHTML = "";

        querySnapshot.forEach(function(doc) {
          var data = doc.data();

          var div = document.createElement("div");
          div.className = "card";

          div.innerHTML = `
            <h3>${data.fullName || ""}</h3>

            ${data.logoBase64 ? `<div class="logo"><img src="data:image/png;base64,${data.logoBase64}"/></div>` : ""}

            <p><b>Phone:</b> ${data.phone || ""}</p>
            <p><b>Platform:</b> ${data.platform || ""}</p>
            <p><b>Role:</b> ${data.role || ""}</p>
            <p><b>Roll No:</b> ${data.rollNumber || ""}</p>
            <p><b>Status:</b> ${data.status || ""}</p>

            <hr>

            <p><b>Account Title:</b> ${data.accountTitle || ""}</p>
            <p><b>Account Number:</b> ${data.accountNumber || ""}</p>
            <p><b>Bank:</b> ${data.bankName || ""}</p>

            <hr>

            <p><b>CNIC:</b> ${data.cnic || ""}</p>
            <p><b>City:</b> ${data.city || ""}</p>
            <p><b>Address:</b> ${data.address || ""}</p>

            <hr>

            <p><b>Applied At:</b> ${
              data.appliedAt ? data.appliedAt.toDate().toLocaleString() : ""
            }</p>

            <div>
              <b>Documents:</b>
              <ul>
                ${(data.documents || []).map(function(d) {
                  return `<li>${d}</li>`;
                }).join("")}
              </ul>
            </div>

            <button onclick="downloadPDF(this)">Download PDF</button>
          `;

          container.appendChild(div);
        });
      })
      .catch(function(error) {
        container.innerHTML = "Error loading data";
        console.error(error);
      });
  }

  // ✅ PDF Download
  function downloadPDF(button) {
    var card = button.parentElement;

    html2pdf()
      .from(card)
      .save("seller_application.pdf");
  }

  loadData();
</script>

</body>
</html>